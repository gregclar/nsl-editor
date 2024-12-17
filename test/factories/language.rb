FactoryBot.define do
  factory :language do
    lock_version { 1 }
    iso6391code { "11" }
    iso6393code { "222" }
    name { "Sample Name" }
  end
end
