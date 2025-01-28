namespace DigitalReceiptBackend.Models;

public class Receipt
{
    public string partitionKey => ReceiptNumber;
    public string id => ReceiptNumber;
    public required string ReceiptNumber { get; init; }
    public required IReadOnlyCollection<Item> Items { get; init; } = new List<Item>();
    public decimal Total => this.Items.Sum(i => i.Total);
    public required string ShopName { get; init; }
}