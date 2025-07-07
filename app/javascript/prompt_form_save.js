let pendingHref = null;
let noUnloadCheck = false;

// Track forms that have been approved by auto-submit handlers to prevent double prompting
const autoSubmitApprovedForms = new WeakMap();

const observer = new MutationObserver(mutations => {
  let nodeClass = "form";
  if (!window.enableSiteWidePromptUnsavedChanges) { nodeClass = "form.prompt-form-save"; }
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === 1 && node.matches && node.matches(nodeClass)) {
        setInitialFormState(node);
      }
      // If forms are nested deeper:
      if (node.nodeType === 1 && node.querySelectorAll) {
        node.querySelectorAll(nodeClass).forEach(setInitialFormState);
      }
    });
  });
});

if (window.enablePromptUnsavedChanges) {
  observer.observe(document.body, { childList: true, subtree: true });
}

// --- Form State Helpers ---
function getFormState(form) {
  const formData = new FormData(form);
  return JSON.stringify(Array.from(formData.entries()));
}

function setInitialFormState(form) {
  form.dataset.initialState = getFormState(form);
}

function hasFormChanged(form) {
  const currentState = getFormState(form);
  const initialState = form.dataset.initialState;
  const hasChanged = currentState !== initialState;
  
  if (hasChanged && typeof debug === "function") {
    debug("Form changed - Current: ", currentState);
    debug("Form changed - Initial: ", initialState);
  }
  
  return hasChanged;
}

function resetFormChanged(form) {
  setInitialFormState(form);
}

function resetAllFormsChanged() {
  const forms = getPromptableForms();
  forms.forEach(form => {
    resetFormChanged(form);
  });
}

function showUnsavedChangesModal(onContinue, onBack, message) {
  const modal = document.getElementById('unsaved-changes-modal');
  const continueBtn = document.getElementById('unsaved-continue');
  const backBtn = document.getElementById('unsaved-back');
  const messageElem = document.getElementById('unsaved-changes-message');
  const defaultMsg = "You have unsaved changes. Continue?";

  if (!modal) {
    console.error('Unsaved changes modal not found');
    return;
  }

  modal.style.display = 'flex';
  if (messageElem) messageElem.textContent = message || defaultMsg;

  if (continueBtn) {
    continueBtn.onclick = () => {
      modal.style.display = 'none';
      if (messageElem) messageElem.textContent = defaultMsg;
      if (typeof onContinue === "function") onContinue();
    };
  }
  if (backBtn) {
    backBtn.onclick = () => {
      modal.style.display = 'none';
      if (messageElem) messageElem.textContent = defaultMsg;
      if (typeof onBack === "function") onBack();
    };
  }
}
function getPromptableForms() {
  let forms;
  if (window.enableSiteWidePromptUnsavedChanges && window.enablePromptUnsavedChanges) {
    forms = Array.from(document.querySelectorAll("form"));
  } else {
    forms = Array.from(document.querySelectorAll("form.prompt-form-save"));
  }
  return forms.filter(form => form.id !== "search-form");
}

function hasUnsavedChangesInOtherForms(currentForm) {
  const forms = getPromptableForms();
  return forms.filter(form => form !== currentForm).some(form => hasFormChanged(form));
}
// --- Global Unsaved Changes Check ---
window.hasUnsavedFormChanges = function() {
  const forms = getPromptableForms();
  return Array.from(forms).some(form => hasFormChanged(form));
};

window.renderFormPrompt = function() {
  // Handle auto-submit dropdowns
  document.querySelectorAll('select.auto-submit-on-change').forEach(select => {
    select.dataset.prevValue = select.value;

    // Remove existing handler if present
    if (select._autoSubmitHandler) {
      select.removeEventListener('change', select._autoSubmitHandler);
    }

    const handler = function(event) {
      const form = select.form;
      if (window.enablePromptUnsavedChanges && hasUnsavedChangesInOtherForms(form)) {
        const doSubmit = () => {
          // Mark this form as approved by auto-submit to prevent double prompting
          autoSubmitApprovedForms.set(form, true);
          try {
            form.requestSubmit ? form.requestSubmit() : form.submit();
          } catch (error) {
            console.error('Form submission failed:', error);
            // Clear the approval flag if submission fails
            autoSubmitApprovedForms.delete(form);
          }
        };
        const doCancel = () => { select.value = select.dataset.prevValue; };
        event.preventDefault();
        if (window.showUnsavedChangesModal) {
          window.showUnsavedChangesModal(doSubmit, doCancel, "You have unsaved changes in other forms. Continue with this action?");
        }
        return false;
      }
      // No unsaved changes, submit as normal
      try {
        form.requestSubmit ? form.requestSubmit() : form.submit();
      } catch (error) {
        console.error('Form submission failed:', error);
      }
    };

    select.addEventListener('change', handler);
    select._autoSubmitHandler = handler;

    // Update prevValue on successful submit
    if (select.form && !select.form._autoSubmitFormHandler) {
      const formHandler = function() {
        select.dataset.prevValue = select.value;
      };
      select.form.addEventListener("submit", formHandler);
      select.form._autoSubmitFormHandler = formHandler;
    }
  });

  if (!window.enablePromptUnsavedChanges) {
    if (typeof debug === "function") debug('Prompt unsaved changes feature is disabled.');
    return;
  }

  // Track changes on all prompt-form-save forms
  const forms = getPromptableForms();
  // Use a WeakMap to track skipNextSubmit per form
  const skipNextSubmitMap = new WeakMap();
  forms.forEach(form => {
    setInitialFormState(form);

    // Remove existing change handlers to prevent double binding
    if (form._changeHandlers) {
      form._changeHandlers.forEach(({ event, handler }) => {
        form.removeEventListener(event, handler);
      });
    }
    form._changeHandlers = [];

    // Add change tracking
    ["input", "change"].forEach(evt => {
      const handler = () => {
        // Don't use dataset.changed, just rely on hasFormChanged
      };
      form.addEventListener(evt, handler);
      form._changeHandlers.push({ event: evt, handler });
    });

    // Remove any previous submit handler to avoid double-binding
    if (form._promptFormSaveHandler) {
      form.removeEventListener("submit", form._promptFormSaveHandler);
    }

    const handler = function(event) {
      if (skipNextSubmitMap.get(form)) {
        skipNextSubmitMap.set(form, false);
        return; // Allow the submit to go through
      }

      const alwaysPrompt = form.classList.contains('always-prompt-before-action');
      if (!alwaysPrompt && !hasFormChanged(form)) {
        resetFormChanged(form);
        return;
      }

      event.preventDefault();
      const submitBtn = form.querySelector('[type="submit"]');
      const submitMsg = "Are you sure you want to submit? This action will save your changes.";

      const doSubmit = () => {
        skipNextSubmitMap.set(form, true);
        try {
          form.requestSubmit ? form.requestSubmit(submitBtn) : form.submit();
        } catch (error) {
          console.error('Form submission failed:', error);
        }
        resetFormChanged(form);
      };
      const onCancel = () => {
        if (submitBtn) submitBtn.disabled = false;
      };

      if (window.showUnsavedChangesModal) {
        window.showUnsavedChangesModal(doSubmit, onCancel, submitMsg);
      } else if (confirm(submitMsg)) {
        doSubmit();
      } else {
        onCancel();
      }
    };

    form.addEventListener("submit", handler);
    form._promptFormSaveHandler = handler;
  });

  // Tab navigation with unsaved changes prompt
  document.querySelectorAll('a.tab').forEach(tab => {
    // Remove existing handler to prevent double binding
    if (tab._tabClickHandler) {
      tab.removeEventListener('click', tab._tabClickHandler);
    }
    
    const handler = function(event) {
      if (window.hasUnsavedFormChanges && window.hasUnsavedFormChanges()) {
        event.preventDefault();
        pendingHref = tab.getAttribute('href');
        
        const proceedWithNavigation = () => {
          if (pendingHref) {
            window.location.href = pendingHref;
            pendingHref = null;
          }
        };
        
        const cancelNavigation = () => {
          pendingHref = null;
        };
        
        if (window.showUnsavedChangesModal) {
          window.showUnsavedChangesModal(proceedWithNavigation, cancelNavigation);
        } else if (confirm("You have unsaved changes. Continue?")) {
          proceedWithNavigation();
        } else {
          cancelNavigation();
        }
      }
    };
    
    tab.addEventListener('click', handler);
    tab._tabClickHandler = handler;
  });
};

window.showUnsavedChangesModal = showUnsavedChangesModal;

$(window).on('beforeunload', function (e) {
  if (window.enablePromptUnsavedChanges && !noUnloadCheck && window.hasUnsavedFormChanges && window.hasUnsavedFormChanges()) {
    e.preventDefault();
    return false;
  }
});

// Clear approval flags on page unload to prevent memory leaks
$(window).on('unload', function() {
  // Note: WeakMap will be garbage collected anyway, but this is good practice
  autoSubmitApprovedForms.clear?.();
});

$('body').on('click', 'a', function(event) {
  const href = $(this).attr('href');
  const isRemote = $(this).attr('data-remote') === 'true';

  if (!href || href.startsWith('#') || $(this).hasClass('no-unsaved-check')) return;

  if (window.enablePromptUnsavedChanges && window.hasUnsavedFormChanges && window.hasUnsavedFormChanges()) {
    event.preventDefault();
    const proceed = () => {
      noUnloadCheck = true;
      if (isRemote) {
        // Perform AJAX call for remote links
        $.ajax({
          url: href,
          type: $(this).attr('data-method') || 'GET',
          dataType: 'script',
          error: function(xhr, status, error) {
            console.error('Remote link failed:', error);
          }
        });
        resetAllFormsChanged();
      } else {
        window.location.href = href;
      }
    };
    
    const cancel = () => {
      // User decided not to proceed
    };
    
    if (window.showUnsavedChangesModal) {
      window.showUnsavedChangesModal(proceed, cancel);
    } else if (confirm("You have unsaved changes. Continue?")) {
      proceed();
    }
    return false;
  }
});

document.body.addEventListener('submit', function(event) {
  const form = event.target;
  if (!(form instanceof HTMLFormElement)) return;

  // Check if this form was already approved by auto-submit handler
  if (autoSubmitApprovedForms.has(form)) {
    // Clear the approval flag and allow submission to proceed
    autoSubmitApprovedForms.delete(form);
    return;
  }

  // Only prompt if there are unsaved changes in *other* forms
  if (window.enablePromptUnsavedChanges && hasUnsavedChangesInOtherForms(form)) {
    event.preventDefault();
    const doSubmit = () => {
      resetAllFormsChanged();
      try {
        form.requestSubmit ? form.requestSubmit() : form.submit();
      } catch (error) {
        console.error('Form submission failed:', error);
      }
    };
    const doCancel = () => {};
    if (window.showUnsavedChangesModal) {
      window.showUnsavedChangesModal(doSubmit, doCancel, "You have unsaved changes in other forms. Continue?");
    } else if (confirm("You have unsaved changes in other forms. Continue?")) {
      doSubmit();
    }
    return false;
  }
  // Otherwise, allow normal logic (including per-form prompt)
}, true);
