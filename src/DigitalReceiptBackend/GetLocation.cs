using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace DigitalReceiptBackend;

public class GetLocation
{
    [Function(nameof(GetLocation))]
    public IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, nameof(HttpMethod.Get))] HttpRequest req)
    {
        var location = Environment.GetEnvironmentVariable("Location") ?? "Unknown";
        return new OkObjectResult(location);
    }
}