# frozen_string_literal: true

# Copyright (c) 2019-2020 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative 'error'
require_relative 'log'

# API first of.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2019-2020 Yegor Bugayenko
# License:: MIT
class Sibit
  # Fist of API.
  class FirstOf
    # Constructor.
    def initialize(list, log: Sibit::Log.new)
      @list = list
      @log = log
    end

    # Current price of BTC in USD (float returned).
    def price(currency = 'USD')
      first_of do |api|
        api.price(currency)
      end
    end

    # Gets the balance of the address, in satoshi.
    def balance(address)
      first_of do |api|
        api.balance(address)
      end
    end

    # Get the height of the block.
    def height(hash)
      first_of do |api|
        api.height(hash)
      end
    end

    # Get the hash of the next block.
    def next_of(hash)
      first_of do |api|
        api.next_of(hash)
      end
    end

    # Get recommended fees, in satoshi per byte. The method returns
    # a hash: { S: 12, M: 45, L: 100, XL: 200 }
    def fees
      first_of(&:fees)
    end

    # Fetch all unspent outputs per address.
    def utxos(keys)
      first_of do |api|
        api.utxos(keys)
      end
    end

    # Latest block hash.
    def latest
      first_of(&:latest)
    end

    # Push this transaction (in hex format) to the network.
    def push(hex)
      first_of do |api|
        api.push(hex)
      end
    end

    # This method should fetch a block and return as a hash.
    def block(hash)
      first_of do |api|
        api.block(hash)
      end
    end

    private

    def first_of
      return yield @list unless @list.is_a?(Array)
      done = false
      result = nil
      @list.each do |api|
        begin
          result = yield api
          done = true
          break
        rescue Sibit::Error => e
          @log.info("The API #{api.class.name} failed: #{e.message}")
        end
      end
      unless done
        raise Sibit::Error, "No APIs out of #{@api.length} managed to succeed: \
#{@api.map { |a| a.class.name }.join(', ')}"
      end
      result
    end
  end
end
