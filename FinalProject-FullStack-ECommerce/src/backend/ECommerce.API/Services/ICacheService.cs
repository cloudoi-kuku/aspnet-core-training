using System;
using System.Threading.Tasks;

namespace ECommerce.API.Services
{
    public interface ICacheService
    {
        Task<T> GetAsync<T>(string key);
        Task<string> GetStringAsync(string key);
        Task SetAsync<T>(string key, T value, TimeSpan? expiration = null);
        Task SetStringAsync(string key, string value, TimeSpan? expiration = null);
        Task<bool> RemoveAsync(string key);
        Task<bool> ExistsAsync(string key);
    }
}