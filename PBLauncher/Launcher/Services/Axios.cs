using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace PBLauncher
{
    public class AxiosResponse<T>
    {
        public T Data { get; set; }
        public int Status { get; set; }
        public string StatusText { get; set; }
        public Dictionary<string, string> Headers { get; set; }
        public AxiosConfig Config { get; set; }
    }

    public class AxiosConfig
    {
        public string Method { get; set; }
        public string Url { get; set; }
        public Dictionary<string, string> Headers { get; set; }
    }

    public class AxiosException : Exception
    {
        public AxiosException(string message) : base(message) { }
        public AxiosException(string message, Exception innerException) : base(message, innerException) { }
    }

    public class Axios
    {
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        private readonly Dictionary<string, string> _defaultHeaders;

        // HttpMethod.Patch personalizado para versiones antiguas de .NET
        private static readonly HttpMethod PatchMethod = new HttpMethod("PATCH");

        public Axios(string baseUrl = "", Dictionary<string, string> defaultHeaders = null)
        {
            _httpClient = new HttpClient();
            _baseUrl = baseUrl;
            _defaultHeaders = defaultHeaders ?? new Dictionary<string, string>();

            // Configurar headers por defecto
            foreach (var header in _defaultHeaders)
            {
                _httpClient.DefaultRequestHeaders.Add(header.Key, header.Value);
            }
        }

        // GET
        public async Task<AxiosResponse<T>> Get<T>(string url, Dictionary<string, string> headers = null)
        {
            return await SendRequest<T>(HttpMethod.Get, url, null, headers);
        }

        // POST
        public async Task<AxiosResponse<T>> Post<T>(string url, object data = null, Dictionary<string, string> headers = null)
        {
            return await SendRequest<T>(HttpMethod.Post, url, data, headers);
        }

        // PUT
        public async Task<AxiosResponse<T>> Put<T>(string url, object data = null, Dictionary<string, string> headers = null)
        {
            return await SendRequest<T>(HttpMethod.Put, url, data, headers);
        }

        // DELETE
        public async Task<AxiosResponse<T>> Delete<T>(string url, Dictionary<string, string> headers = null)
        {
            return await SendRequest<T>(HttpMethod.Delete, url, null, headers);
        }

        // PATCH
        public async Task<AxiosResponse<T>> Patch<T>(string url, object data = null, Dictionary<string, string> headers = null)
        {
            return await SendRequest<T>(PatchMethod, url, data, headers);
        }

        private async Task<AxiosResponse<T>> SendRequest<T>(HttpMethod method, string url, object data = null, Dictionary<string, string> headers = null)
        {
            try
            {
                var fullUrl = string.IsNullOrEmpty(_baseUrl) ? url : $"{_baseUrl.TrimEnd('/')}/{url.TrimStart('/')}";
                var request = new HttpRequestMessage(method, fullUrl);

                // Agregar headers específicos de la petición
                if (headers != null)
                {
                    foreach (var header in headers)
                    {
                        request.Headers.Add(header.Key, header.Value);
                    }
                }

                // Agregar body si hay data
                if (data != null && (method == HttpMethod.Post || method == HttpMethod.Put || method == PatchMethod))
                {
                    var json = JsonConvert.SerializeObject(data);
                    request.Content = new StringContent(json, Encoding.UTF8, "application/json");
                }

                var response = await _httpClient.SendAsync(request);
                var responseContent = await response.Content.ReadAsStringAsync();

                return new AxiosResponse<T>
                {
                    Data = string.IsNullOrEmpty(responseContent) ? default(T) : JsonConvert.DeserializeObject<T>(responseContent),
                    Status = (int)response.StatusCode,
                    StatusText = response.ReasonPhrase,
                    Headers = GetResponseHeaders(response),
                    Config = new AxiosConfig
                    {
                        Method = method.Method,
                        Url = fullUrl,
                        Headers = headers
                    }
                };
            }
            catch (HttpRequestException ex)
            {
                throw new AxiosException($"Error en la petición HTTP: {ex.Message}", ex);
            }
            catch (JsonException ex)
            {
                throw new AxiosException($"Error al deserializar la respuesta JSON: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                throw new AxiosException($"Error inesperado: {ex.Message}", ex);
            }
        }

        private Dictionary<string, string> GetResponseHeaders(HttpResponseMessage response)
        {
            var headers = new Dictionary<string, string>();

            foreach (var header in response.Headers)
            {
                headers[header.Key] = string.Join(", ", header.Value);
            }

            foreach (var header in response.Content.Headers)
            {
                headers[header.Key] = string.Join(", ", header.Value);
            }

            return headers;
        }

        public void Dispose()
        {
            _httpClient?.Dispose();
        }
    }
}