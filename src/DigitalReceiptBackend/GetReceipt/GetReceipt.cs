using DigitalReceiptBackend.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace DigitalReceiptBackend.GetReceipt;

public class GetReceipt
{
    private readonly ILogger<GetReceipt> _logger;

    public GetReceipt(ILogger<GetReceipt> logger)
    {
        this._logger = logger;
    }

    [Function("GetReceipt")]
    public IActionResult Run(
        [HttpTrigger(AuthorizationLevel.Function, nameof(HttpMethod.Get), Route = "receipts/{ReceiptId}")]
        HttpRequest req,
        [CosmosDBInput("receipts", "receipts", Connection = "CosmosDBConnection", Id = "{ReceiptId}", PartitionKey = "{ReceiptId}", PreferredLocations = "%Location%")]
        Receipt? receipt)
    {
        this._logger.LogInformation("C# HTTP trigger function processed a request.");
        if (receipt == null)
        {
            return new NotFoundResult();
        }
        
        return new OkObjectResult(receipt);
    }

}