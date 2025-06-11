using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace ECommerce.API.Services
{
    public class NotificationProcessingService : BackgroundService
    {
        private readonly ILogger<NotificationProcessingService> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _checkInterval = TimeSpan.FromSeconds(10);

        public NotificationProcessingService(
            ILogger<NotificationProcessingService> logger,
            IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Notification Processing Service started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessNotificationQueueAsync(stoppingToken);
                    await Task.Delay(_checkInterval, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    // Expected when cancellation is requested
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error occurred while processing notifications");
                    await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
                }
            }

            _logger.LogInformation("Notification Processing Service stopped");
        }

        private async Task ProcessNotificationQueueAsync(CancellationToken cancellationToken)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var messageQueueService = scope.ServiceProvider.GetRequiredService<IMessageQueueService>();
                var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

                // Process email notifications
                await ProcessQueueAsync<EmailNotificationMessage>(
                    messageQueueService,
                    "email-notifications",
                    async (message) =>
                    {
                        await notificationService.SendEmailAsync(new EmailNotification
                        {
                            To = message.To,
                            Subject = message.Subject,
                            Body = message.Body,
                            IsHtml = message.IsHtml
                        });
                    },
                    cancellationToken);

                // Process SMS notifications
                await ProcessQueueAsync<SmsNotificationMessage>(
                    messageQueueService,
                    "sms-notifications",
                    async (message) =>
                    {
                        await notificationService.SendSmsAsync(new SmsNotification
                        {
                            PhoneNumber = message.PhoneNumber,
                            Message = message.Message
                        });
                    },
                    cancellationToken);

                // Process push notifications
                await ProcessQueueAsync<PushNotificationMessage>(
                    messageQueueService,
                    "push-notifications",
                    async (message) =>
                    {
                        await notificationService.SendPushNotificationAsync(new PushNotification
                        {
                            UserId = message.UserId,
                            Title = message.Title,
                            Body = message.Body,
                            Data = message.Data
                        });
                    },
                    cancellationToken);
            }
        }

        private async Task ProcessQueueAsync<T>(
            IMessageQueueService messageQueueService,
            string queueName,
            Func<T, Task> processFunc,
            CancellationToken cancellationToken)
        {
            try
            {
                // Try to receive a message with a short timeout
                var message = await messageQueueService.ReceiveAsync<T>(queueName, TimeSpan.FromSeconds(1));
                
                if (message != null && !cancellationToken.IsCancellationRequested)
                {
                    _logger.LogInformation($"Processing {typeof(T).Name} from queue: {queueName}");
                    
                    try
                    {
                        await processFunc(message);
                        _logger.LogInformation($"Successfully processed {typeof(T).Name}");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, $"Failed to process {typeof(T).Name}");
                        // In a real implementation, you might want to requeue the message
                    }
                }
            }
            catch (OperationCanceledException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error processing queue: {queueName}");
            }
        }
    }

    // Message types for the queues
    public class EmailNotificationMessage
    {
        public string To { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
        public bool IsHtml { get; set; }
    }

    public class SmsNotificationMessage
    {
        public string PhoneNumber { get; set; }
        public string Message { get; set; }
    }

    public class PushNotificationMessage
    {
        public string UserId { get; set; }
        public string Title { get; set; }
        public string Body { get; set; }
        public object Data { get; set; }
    }
}