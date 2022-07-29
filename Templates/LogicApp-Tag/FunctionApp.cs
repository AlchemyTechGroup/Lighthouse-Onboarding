using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

// Update customerId to your Log Analytics workspace ID
static string customerId = "c8cdcb56-3051-4dc8-8c39-02e8db292568";

// For sharedKey, use either the primary or the secondary Connected Sources client authentication key   
static string sharedKey = "p2jumjKQ+ZmagyvnrTfXFBl8zkPlMwVffDik4HYwrXiWVTWbhsInuISBdbgrMucIDthukiW2lC80svrNE/I52Q==";

// LogName is name of the event type that is being submitted to Log Analytics
static string LogName = "CustomTagData";

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info("Starting OMS proxy execution...");

    // Create a hash for the API signature
    var datestring = DateTime.UtcNow.ToString("r");
    var rawPayload = await req.Content.ReadAsStringAsync();
    var jsonBytes = Encoding.UTF8.GetBytes(rawPayload);
    var stringToHash = "POST\n" + jsonBytes.Length + "\napplication/json\n" + "x-ms-date:" + datestring + "\n/api/logs";
    var hashedString = BuildSignature(stringToHash, sharedKey);
    var signature = "SharedKey " + customerId + ":" + hashedString;

    // Insert data in OMS
    PostData(signature, datestring, rawPayload, log);

    // Indicate success
    return req.CreateResponse(HttpStatusCode.OK, "Successful");
}

// Build the API signature
public static string BuildSignature(string message, string secret)
{
    var encoding = new System.Text.ASCIIEncoding();
    byte[] keyByte = Convert.FromBase64String(secret);
    byte[] messageBytes = encoding.GetBytes(message);
    using (var hmacsha256 = new HMACSHA256(keyByte))
    {
        byte[] hash = hmacsha256.ComputeHash(messageBytes);
        return Convert.ToBase64String(hash);
    }
}

// Send a request to the POST API endpoint
public static void PostData(string signature, string date, string json, TraceWriter log)
{
    try
    {
        var url = "https://" + customerId + ".ods.opinsights.azure.com/api/logs?api-version=2016-04-01";
        var client = new System.Net.Http.HttpClient();
        client.DefaultRequestHeaders.Add("Accept", "application/json");
        client.DefaultRequestHeaders.Add("Log-Type", LogName);
        client.DefaultRequestHeaders.Add("Authorization", signature);
        client.DefaultRequestHeaders.Add("x-ms-date", date);

        var httpContent = new StringContent(json, Encoding.UTF8);
        httpContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
        Task<System.Net.Http.HttpResponseMessage> response = client.PostAsync(new Uri(url), httpContent);

        var responseContent = response.Result.Content;
        var result = responseContent.ReadAsStringAsync().Result;
        log.Info("Return Result: " + result);
    }
    catch (Exception excep)
    {
        log.Info("API Post Exception: " + excep.Message);
    }
}     