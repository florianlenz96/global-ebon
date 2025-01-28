using Azure.Storage.Queues.Models;
using DigitalReceiptBackend.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace DigitalReceiptBackend.OrderCompleted;

public class OrderCompletedHandler
{
    private readonly ILogger<OrderCompletedHandler> _logger;

    public OrderCompletedHandler(ILogger<OrderCompletedHandler> logger)
    {
        this._logger = logger;
    }

    [Function(nameof(OrderCompletedHandler))]
    [CosmosDBOutput("receipts", "receipts", Connection = "CosmosDBConnection")]
    public Receipt? Run(
        [QueueTrigger("order-completed", Connection = "AzureWebJobsStorage")]
        QueueMessage message)
    {
        this._logger.LogInformation($"C# Queue trigger function processed: {message.MessageText}");
        return JsonConvert.DeserializeObject<Receipt>(message.MessageText);
    }
}