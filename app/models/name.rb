class Name < ApplicationRecord
  self.table_name = "name"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"
end
