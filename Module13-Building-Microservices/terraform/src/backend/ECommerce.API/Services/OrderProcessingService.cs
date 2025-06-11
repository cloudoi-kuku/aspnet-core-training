using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace ECommerce.API.Services
{
    public class OrderProcessingService : BackgroundService
    {
        private readonly ILogger<OrderProcessingService> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _checkInterval = TimeSpan.FromSeconds(30);

        public OrderProcessingService(
            ILogger<OrderProcessingService> logger,
            IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Order Processing Service started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessPendingOrdersAsync(stoppingToken);
                    await Task.Delay(_checkInterval, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Expected when cancellation is requested
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while processing orders");
                    await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                }
            }

            _logger.LogInformation("Order Processing Service stopped");
        }

        private async Task ProcessPendingOrdersAsync(CancellationToken cancellationToken)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var messageQueueService = scope.ServiceProvider.GetRequiredService<IMessageQueueService>();
                var orderService = scope.ServiceProvider.GetRequiredService<IOrderService>();
                var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

                // Subscribe to order processing queue
                await messageQueueService.SubscribeAsync<OrderProcessingMessage>(
                    "order-processing",
                    async (message) =>
                    {
                        await ProcessOrderAsync(message, orderService, notificationService);
                    });

                // Check for any pending orders in a real scenario
                _logger.LogDebug("Checking for pending orders...");
                
                // Simulate order processing
                var simulatedOrder = new OrderProcessingMessage
                {
                    OrderId = new Random().Next(1, 1000),
                    Action = "process",
                    Timestamp = DateTime.UtcNow
                };

                if (simulatedOrder.OrderId % 10 == 0) // Process every 10th order
                {
                    await ProcessOrderAsync(simulatedOrder, orderService, notificationService);
                }
            }
        }

        private async Task ProcessOrderAsync(
            OrderProcessingMessage message,
            IOrderService orderService,
            INotificationService notificationService)
        {
            _logger.LogInformation($"Processing order: {message.OrderId}, Action: {message.Action}");

            try
            {
                switch (message.Action.ToLower())
                {
                    case "process":
                        // Update order status to Processing
                        await orderService.UpdateOrderStatusAsync(message.OrderId, "Processing");
                        
                        // Simulate order processing
                        await Task.Delay(TimeSpan.FromSeconds(2));
                        
                        // Update order status to Completed
                        await orderService.UpdateOrderStatusAsync(message.OrderId, "Completed");
                        
                        // Send confirmation notification
                        await notificationService.SendOrderConfirmationAsync(message.OrderId);
                        break;

                    case "cancel":
                        await orderService.CancelOrderAsync(message.OrderId);
                        break;

                    default:
                        _logger.LogWarning($"Unknown action: {message.Action}");
                        break;
                }

                _logger.LogInformation($"Successfully processed order: {message.OrderId}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to process order: {message.OrderId}");
                throw;
            }
        }
    }

    public class OrderProcessingMessage
    {
        public int OrderId { get; set; }
        public string Action { get; set; }
        public DateTime Timestamp { get; set; }
    }
}