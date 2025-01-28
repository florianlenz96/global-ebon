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
        HttpRequest req)
        //[CosmosDBInput("receipts", "receipts", Connection = "CosmosDBConnection", Id = "{ReceiptId}", PartitionKey = "{ReceiptId}", PreferredLocations = "%Location%")]
        //Receipt? receipt)
    {
        var receipt = new Receipt
        {
            ReceiptNumber = req.RouteValues["ReceiptId"].ToString(),
            ShopName = "Shop",
            ReceiptDate = DateTime.UtcNow,
            Items = new List<Item>
            {
                new Item
                {
                    Price = 1.23m,
                    Quantity = 2,
                    ProductName = "Product 1",
                    Total = 2.46m
                },
                new Item
                {
                    Price = 2.23m,
                    Quantity = 1,
                    ProductName = "Product 2",
                    Total = 2.23m
                }
            }
        };
        
        return new OkObjectResult(receipt);
    }

}