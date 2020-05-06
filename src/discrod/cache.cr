module Discrod
    abstract class Cache(T)
        getter map : Hash(Snowflake, T) = Hash(Snowflake, T).new
        getter clear_fiber : Fiber?
        property client_dead : Bool = false

        abstract def resolve(id : Snowflake) : T?

        def clear
            @map = map.clear
        end

        def clear_periodic(span : Time::Span)
            clear_fiber = spawn do
                loop do
                    sleep span
                    break if @client_dead
                    clear
                end
            end
        end

        def get(id : Snowflake) : T?
            map[id]? || resolve(id)
        end

        def get(id : UInt64 | String) : T
            get(Snowflake.new(id))
        end

        def get!(id : Snowflake) : T
            map[id]? || resolve(id).not_nil!
        end

        def get!(id : UInt64 | String) : T
            get!(Snowflake.new(id))
        end

        def <<(resource : T)
            if resource.responds_to?(:id)
                map[resource.id] = resource
            end
        end

        def delete(id : Snowflake)
            map.delete(id)
        end

        def delete(resource : T)
            if resource.responds_to?(:id)
                map.delete(resource.id)
            end
        end

        def initialize(@client : Client)
        end
    end

    class GuildCache < Cache(Guild)
        def resolve(id : Snowflake) : Guild?
            map[id] = @client.get_guild(id)
            map[id]?
        end
    end

    class ChannelCache < Cache(Channel)
        def resolve(id : Snowflake) : Channel?
            map[id] = @client.get_channel(id)
            map[id]?
        end
    end

    class UserCache < Cache(User)
        def resolve(id : Snowflake) : User?
            map[id] = @client.get_user(id)
            map[id]?
        end
    end

    class RoleCache < Cache(Role)
        def resolve(id : Snowflake) : Role?
            map[id]?
        end
    end
end
