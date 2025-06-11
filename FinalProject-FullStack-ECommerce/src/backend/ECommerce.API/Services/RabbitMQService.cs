using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace ECommerce.API.Services
{
    public class RabbitMQService : IMessageQueueService
    {
        private readonly ILogger<RabbitMQService> _logger;
        private readonly ConcurrentDictionary<string, Queue<QueueMessage<object>>> _queues;
        private readonly ConcurrentDictionary<string, List<Func<object, Task>>> _handlers;

        public RabbitMQService(ILogger<RabbitMQService> logger)
        {
            _logger = logger;
            _queues = new ConcurrentDictionary<string, Queue<QueueMessage<object>>>();
            _handlers = new ConcurrentDictionary<string, List<Func<object, Task>>>();
        }

        public async Task PublishAsync<T>(string queueName, T message)
        {
            _logger.LogInformation($"Publishing message to queue: {queueName}");
            
            var queue = _queues.GetOrAdd(queueName, _ => new Queue<QueueMessage<object>>());
            var queueMessage = new QueueMessage<object>
            {
                Id = Guid.NewGuid().ToString(),
                Body = message,
                Timestamp = DateTime.UtcNow,
                DeliveryCount = 0
            };
            
            queue.Enqueue(queueMessage);
            
            // Trigger handlers if any
            if (_handlers.TryGetValue(queueName, out var handlers))
            {
                foreach (var handler in handlers)
                {
                    await handler(message);
                }
            }
            
            await Task.CompletedTask;
        }

        public async Task SubscribeAsync<T>(string queueName, Func<T, Task> handler)
        {
            _logger.LogInformation($"Subscribing to queue: {queueName}");
            
            var handlers = _handlers.GetOrAdd(queueName, _ => new List<Func<object, Task>>());
            handlers.Add(async (obj) =>
            {
                if (obj is T typedMessage)
                {
                    await handler(typedMessage);
                }
                else
                {
                    // Try to deserialize if it's a JSON string
                    try
                    {
                        var json = JsonSerializer.Serialize(obj);
                        var deserializedMessage = JsonSerializer.Deserialize<T>(json);
                        await handler(deserializedMessage);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to process message");
                    }
                }
            });
            
            await Task.CompletedTask;
        }

        public async Task<T> ReceiveAsync<T>(string queueName, TimeSpan? timeout = null)
        {
            _logger.LogInformation($"Receiving message from queue: {queueName}");
            
            var endTime = timeout.HasValue ? DateTime.UtcNow.Add(timeout.Value) : DateTime.MaxValue;
            
            while (DateTime.UtcNow < endTime)
            {
                if (_queues.TryGetValue(queueName, out var queue) && queue.Count > 0)
                {
                    var message = queue.Dequeue();
                    message.DeliveryCount++;
                    
                    if (message.Body is T typedMessage)
                    {
                        return await Task.FromResult(typedMessage);
                    }
                    
                    // Try to deserialize
                    try
                    {
                        var json = JsonSerializer.Serialize(message.Body);
                        var deserializedMessage = JsonSerializer.Deserialize<T>(json);
                        return await Task.FromResult(deserializedMessage);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to deserialize message");
                    }
                }
                
                await Task.Delay(100);
            }
            
            return await Task.FromResult(default(T));
        }

        public async Task AcknowledgeAsync(string queueName, string messageId)
        {
            _logger.LogInformation($"Acknowledging message {messageId} in queue: {queueName}");
            // In a real implementation, this would mark the message as processed
            await Task.CompletedTask;
        }

        public async Task RejectAsync(string queueName, string messageId, bool requeue = true)
        {
            _logger.LogInformation($"Rejecting message {messageId} in queue: {queueName}, requeue: {requeue}");
            // In a real implementation, this would handle message rejection and requeuing
            await Task.CompletedTask;
        }
    }
}