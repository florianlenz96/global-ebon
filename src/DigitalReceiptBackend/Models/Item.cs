namespace DigitalReceiptBackend.Models;

public class Item
{
    public required string ProductName { get; init; }
    public required int Quantity { get; init; }
    public required decimal Price { get; init; }
    public required decimal Total { get; init; }
}