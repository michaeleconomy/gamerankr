    # Subclasses must implement:
    #   - {#cursor_from_node}, which returns an opaque cursor for the given item
    #   - {#sliced_nodes}, which slices by `before` & `after`
    #   - {#paged_nodes}, which applies `first` & `last` limits
    #
    # In a subclass, you have access to
    #   - {#nodes}, the collection which the connection will wrap
    #   - {#first}, {#after}, {#last}, {#before} (arguments passed to the field)
    #   - {#max_page_size} (the specified maximum page size that can be returned from a connection)
    #
# Rails.application.config.after_initialize do
#   module GraphQL
#     module Relay
#       class WillPaginateConnection < BaseConnection
#         def cursor_from_node(item)
#           item_index = paged_nodes.index(item)
#           if item_index.nil?
#             raise("Can't generate cursor, item not found in connection: #{item}")
#           else
#             # offset = item_index + 1 + ((paged_nodes_offset || 0) - (relation_offset(sliced_nodes) || 0))

#             # if after
#             #   offset += offset_from_cursor(after)
#             # elsif before
#             #   offset += offset_from_cursor(before) - 1 - sliced_nodes_count
#             # end

#             # encode(offset.to_s)
#             encode(nodes.next_page.to_s)
#           end
#         end

#         private

#         # apply first / last limit results
#         # @return [Array]
#         def paged_nodes
#           nodes
#         end

#         # Apply cursors to edges
#         def sliced_nodes
#           nodes
#         end
#         BaseConnection.register_connection_implementation(WillPaginate::Collection, WillPaginateConnection)
#       end
#     end
#   end
# end