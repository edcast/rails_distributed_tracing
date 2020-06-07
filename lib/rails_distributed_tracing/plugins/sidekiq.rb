module DistributedTracing
  module SidekiqMiddleware
    class Client
      def call(worker_class, job, queue, redis_pool)
        tag = "#{worker_class.to_s} #{SecureRandom.hex(12)}"
        ::Rails.logger.tagged(tag) do
          job_info = "Start at11 #{Time.now.to_default_s}: #{job.inspect}"
          ::Rails.logger.info(job_info)
          yield
        end        
        #job[DistributedTracing::TRACE_ID] = trace_id
        #yield
      end

      private
      def trace_id
        DistributedTracing.trace_id || SecureRandom.uuid
      end
    end

    class Server
      def call(worker, job, queue)
        logger = worker.logger

        if logger.respond_to?(:tagged)
          DistributedTracing.trace_id = job[DistributedTracing::TRACE_ID]
          logger.tagged(DistributedTracing.trace_id) {yield}
          DistributedTracing.trace_id= nil
        else
          yield
        end
      end
    end
  end
end
