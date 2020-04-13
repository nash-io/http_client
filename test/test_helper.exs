Mox.defmock(HttpClient.HttpClientMockImpl, for: HttpClient)

ExUnit.configure(formatters: [ExUnit.CLIFormatter, ExUnitSonarqube])
ExUnit.start()
