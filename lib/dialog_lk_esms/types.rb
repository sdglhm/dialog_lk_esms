require "dry-types"

module DialogLkEsms
  module Types
    include Dry.Types()
    
    PhoneList = Types::Array.of(Types::String.constrained(format: /\A\+?\d{6,15}\z/)).meta(omittable: false)
    MessageText = Types::String.constrained(min_size: 1)
    SourceAddr = Types::String.constrained(min_size: 1)
    
    
    StatusCode = Types::String
    
    
    Balance = Types::Decimal | Types::Float | Types::Coercible::Decimal | Types::Coercible::Float
    
    
    ResponseStruct = Types::Hash.schema(
      code: StatusCode,
      ok: Types::Bool,
      message: Types::String,
      raw: Types::String.optional,
      payload: Types::Hash.optional
    )
  end
end