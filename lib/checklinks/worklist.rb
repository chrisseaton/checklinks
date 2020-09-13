module Checklinks
  # A worklist is a list of jobs to do and possibly a pool of threads
  # working on it
  class Worklist
    # Create a worklist, possibly with a list of jobs to start with
    def initialize(*jobs)
      @state = nil
      @queue = Queue.new
      @active = Queue.new
      @processing = false
      push *jobs
    end

    # Push more jobs onto the worklist
    def push(*jobs)
      jobs.each do |job|
        raise unless job
        @queue.push job
      end
    end

    # Process the jobs in the worklist in a background thread. You can pass a
    # state object which is then passed into the block to process each job.
    def process(state=nil)
      @state = state
      process_concurrently(1) do |job|
        yield job, @state
      end
    end

    # Process the jobs in the worklist in multiple concurrent background threads
    def process_concurrently(n)
      raise if @threads
      @threads = n.times.map {
        Thread.new {
          until @queue.closed? && @queue.empty?
            job = @queue.pop
            next unless job
            @active.push :active
            yield job
            @active.pop
          end
        }
      }
    end

    # How many jobs are left to process
    def size
      # This is a a bit racy - we don't update these two queues atomically
      @queue.size + @active.size
    end

    # Declare that you're not going to push any more jobs, and wait for the
    # current jobs to be processed if you've started that
    def close
      @threads.size.times do
        @queue.push nil
      end
      @queue.close
      @threads.each &:join
      @state
    end

    # Close a set of worklists
    def self.close(*worklists)
      worklists.map(&:close)
    end

    # Create a worklist that collects values into an array and returns
    # it when closed
    def self.collector
      worklist = Worklist.new
      worklist.process([]) do |value, collected|
        collected.push value
      end
      worklist
    end
  end
end
