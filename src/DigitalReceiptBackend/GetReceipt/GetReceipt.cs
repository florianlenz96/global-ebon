using DigitalReceiptBackend.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;

namespace DigitalReceiptBackend.GetReceipt;

public class GetReceipt
{
    [Function("GetReceipt")]
    public IActionResult Run(
        [HttpTrigger(AuthorizationLevel.Function, nameof(HttpMethod.Get), Route = "receipts/{ReceiptId}")]
        HttpRequest req,
        [CosmosDBInput("receipts", "receipts", Connection = "CosmosDBConnection", Id = "{ReceiptId}", PartitionKey = "{ReceiptId}", PreferredLocations = "%Location%")]
        Receipt? receipt)
    {
        if (receipt == null)
        {
            return new NotFoundResult();
        }
        
        return new OkObjectResult(receipt);
    }

}