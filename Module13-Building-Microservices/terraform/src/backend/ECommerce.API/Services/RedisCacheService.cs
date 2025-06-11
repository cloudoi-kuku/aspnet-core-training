using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace ECommerce.API.Services
{
    public class RedisCacheService : ICacheService
    {
        private readonly ILogger<RedisCacheService> _logger;
        private readonly Dictionary<string, CacheEntry> _cache = new Dictionary<string, CacheEntry>();

        public RedisCacheService(ILogger<RedisCacheService> logger)
        {
            _logger = logger;
        }

        public async Task<T> GetAsync<T>(string key)
        {
            _logger.LogInformation($"Getting cache value for key: {key}");
            
            if (_cache.TryGetValue(key, out var entry) && !entry.IsExpired())
            {
                var json = entry.Value as string;
                if (!string.IsNullOrEmpty(json))
                {
                    return JsonSerializer.Deserialize<T>(json);
                }
            }
            
            return await Task.FromResult(default(T));
        }

        public async Task<string> GetStringAsync(string key)
        {
            _logger.LogInformation($"Getting string cache value for key: {key}");
            
            if (_cache.TryGetValue(key, out var entry) && !entry.IsExpired())
            {
                return await Task.FromResult(entry.Value as string);
            }
            
            return await Task.FromResult<string>(null);
        }

        public async Task SetAsync<T>(string key, T value, TimeSpan? expiration = null)
        {
            _logger.LogInformation($"Setting cache value for key: {key}");
            
            var json = JsonSerializer.Serialize(value);
            var entry = new CacheEntry
            {
                Value = json,
                Expiration = expiration.HasValue ? DateTime.UtcNow.Add(expiration.Value) : null
            };
            
            _cache[key] = entry;
            await Task.CompletedTask;
        }

        public async Task SetStringAsync(string key, string value, TimeSpan? expiration = null)
        {
            _logger.LogInformation($"Setting string cache value for key: {key}");
            
            var entry = new CacheEntry
            {
                Value = value,
                Expiration = expiration.HasValue ? DateTime.UtcNow.Add(expiration.Value) : null
            };
            
            _cache[key] = entry;
            await Task.CompletedTask;
        }

        public async Task<bool> RemoveAsync(string key)
        {
            _logger.LogInformation($"Removing cache value for key: {key}");
            return await Task.FromResult(_cache.Remove(key));
        }

        public async Task<bool> ExistsAsync(string key)
        {
            _logger.LogInformation($"Checking if key exists: {key}");
            
            if (_cache.TryGetValue(key, out var entry))
            {
                if (!entry.IsExpired())
                {
                    return await Task.FromResult(true);
                }
                
                _cache.Remove(key);
            }
            
            return await Task.FromResult(false);
        }

        private class CacheEntry
        {
            public object Value { get; set; }
            public DateTime? Expiration { get; set; }

            public bool IsExpired()
            {
                return Expiration.HasValue && Expiration.Value < DateTime.UtcNow;
            }
        }
    }
}