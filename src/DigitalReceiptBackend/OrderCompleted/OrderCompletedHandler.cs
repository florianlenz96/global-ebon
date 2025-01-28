using Azure.Storage.Queues.Models;
using DigitalReceiptBackend.Models;
using Microsoft.Azure.Functions.Worker;
using Newtonsoft.Json;

namespace DigitalReceiptBackend.OrderCompleted;

public class OrderCompletedHandler
{
    [Function(nameof(OrderCompletedHandler))]
    [CosmosDBOutput("receipts", "receipts", Connection = "CosmosDBConnection")]
    public Receipt? Run(
        [QueueTrigger("order-completed", Connection = "AzureWebJobsStorage")]
        QueueMessage message)
    {
        return JsonConvert.DeserializeObject<Receipt>(message.MessageText);
    }
}