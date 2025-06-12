using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

public static class GameAccess
{
    private static CancellationTokenSource _cancellationTokenSource;
    public static void Start(int clientStartPort, int clientEndPort, string serverHost, int serverStartPort)
    {
        _cancellationTokenSource = new CancellationTokenSource();
        CancellationToken token = _cancellationTokenSource.Token;

        for (int port = clientStartPort; port <= clientEndPort; port++)
        {
            int clientPort = port;
            int serverPort = serverStartPort + (clientPort - clientStartPort);
            Task.Run(() => StartListener(serverHost, clientPort, serverPort, token), token);
        }
    }
    public static void Stop()
    {
        _cancellationTokenSource?.Cancel();
    }
    private static async Task StartListener(string serverHost, int clientPort, int serverPort, CancellationToken token)
    {
        TcpListener listener = new TcpListener(IPAddress.Any, clientPort);
        listener.Start();

        while (!token.IsCancellationRequested)
        {
            TcpClient client = await Task.Run(() => listener.AcceptTcpClient(), token);
            TcpClient server = new TcpClient(serverHost, serverPort);
            _ = Task.Run(() => HandleClient(client, server, token), token);
        }
    }
    private static async Task HandleClient(TcpClient clientSocket, TcpClient serverSocket, CancellationToken token)
    {
        using (NetworkStream clientStream = clientSocket.GetStream())
        using (NetworkStream serverStream = serverSocket.GetStream())
        {
            Task clientToServer = RelayTraffic(clientStream, serverStream, "Client to Server", token);
            Task serverToClient = RelayTraffic(serverStream, clientStream, "Server to Client", token);
            await Task.WhenAny(clientToServer, serverToClient);
        }
        clientSocket.Close();
        serverSocket.Close();
    }
    private static async Task RelayTraffic(NetworkStream input, NetworkStream output, string direction, CancellationToken token)
    {
        byte[] buffer = new byte[16384];
        while (!token.IsCancellationRequested)
        {
            int bytesRead = await input.ReadAsync(buffer, 0, buffer.Length, token);
            if (bytesRead == 0) break;
            string data = Encoding.UTF8.GetString(buffer, 0, bytesRead);
            await output.WriteAsync(buffer, 0, bytesRead, token);
        }
    }
}
