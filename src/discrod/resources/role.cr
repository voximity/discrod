module Discrod
    class Role
        include JSON::Serializable

        getter id : Snowflake
        getter name : String
        getter color : Int32
        getter hoist : Bool
        getter position : Int32
        getter permissions : Permissions
        getter managed : Bool
        getter mentionable : Bool
    end
end