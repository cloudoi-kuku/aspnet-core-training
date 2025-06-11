using System;
using System.Threading.Tasks;

namespace ECommerce.API.Services
{
    public interface IMessageQueueService
    {
        Task PublishAsync<T>(string queueName, T message);
        Task SubscribeAsync<T>(string queueName, Func<T, Task> handler);
        Task<T> ReceiveAsync<T>(string queueName, TimeSpan? timeout = null);
        Task AcknowledgeAsync(string queueName, string messageId);
        Task RejectAsync(string queueName, string messageId, bool requeue = true);
    }

    public class QueueMessage<T>
    {
        public string Id { get; set; }
        public T Body { get; set; }
        public DateTime Timestamp { get; set; }
        public int DeliveryCount { get; set; }
    }
}