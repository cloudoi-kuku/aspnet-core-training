using System.Threading.Tasks;

namespace ECommerce.API.Services
{
    public interface INotificationService
    {
        Task SendEmailAsync(EmailNotification notification);
        Task SendSmsAsync(SmsNotification notification);
        Task SendPushNotificationAsync(PushNotification notification);
        Task SendOrderConfirmationAsync(int orderId);
        Task SendPasswordResetAsync(string email, string resetToken);
        Task SendWelcomeEmailAsync(string email, string userName);
    }

    public class EmailNotification
    {
        public string To { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
        public bool IsHtml { get; set; }
    }

    public class SmsNotification
    {
        public string PhoneNumber { get; set; }
        public string Message { get; set; }
    }

    public class PushNotification
    {
        public string UserId { get; set; }
        public string Title { get; set; }
        public string Body { get; set; }
        public object Data { get; set; }
    }
}