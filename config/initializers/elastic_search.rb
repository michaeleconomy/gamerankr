
# require 'faraday_middleware/aws_signers_v4'
# require 'elasticsearch'

# Elasticsearch::Model.client = Elasticsearch::Client.new url: 'https://search-gamerankr-games-zyk4jociabborehk6iesomnqum.us-east-1.es.amazonaws.com' do |f|
#   f.request :aws_signers_v4,
#             credentials: Aws::Credentials.new(Secret['AWS_ELASTICSEARCH_KEY'], Secret['AWS_ELASTICSEARCH_SECRET']),
#             service_name: 'es',
#             region: 'us-east-1'
# end