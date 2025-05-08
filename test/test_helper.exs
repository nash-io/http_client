Mox.defmock(HttpClient.HttpClientMockImpl, for: HttpClient)

Application.put_env(:http_client, :http_client_impl, HttpClient.HttpClientMockImpl)

ExUnit.configure(formatters: [ExUnit.CLIFormatter])
ExUnit.start()