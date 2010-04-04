module Backup
  module Storage
    class S3
      
      # Stores the backup file on the remote server using S3
      def initialize(adapter)
        s3 = Backup::Connection::S3.new(adapter)
        s3.connect
        s3.store
      end
      
    end
  end
end