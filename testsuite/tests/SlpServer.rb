# encoding: utf-8

module Yast
  class SlpServerClient < Client
    def main
      # testedfiles: SlpServer.ycp

      Yast.include self, "testsuite.rb"
      TESTSUITE_INIT([], nil)

      Yast.import "SlpServer"

      DUMP("SlpServer::Modified")
      TEST(lambda { SlpServer.Modified }, [], nil)

      nil
    end
  end
end

Yast::SlpServerClient.new.main
