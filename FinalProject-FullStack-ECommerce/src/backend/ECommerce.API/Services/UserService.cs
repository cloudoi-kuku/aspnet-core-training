using ECommerce.API.Models;
using ECommerce.API.DTOs;

namespace ECommerce.API.Services;

public class UserService : IUserService
{
    private readonly List<User> _users = new();
    private readonly ILogger<UserService> _logger;
    private int _nextId = 1;

    public UserService(ILogger<UserService> logger)
    {
        _logger = logger;
        
        // Seed with a default admin user
        _users.Add(new User
        {
            Id = _nextId++,
            Email = "admin@example.com",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
            FirstName = "Admin",
            LastName = "User",
            Role = "Admin",
            IsActive = true
        });
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        return await Task.FromResult(_users.Where(u => u.IsActive));
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await Task.FromResult(_users.FirstOrDefault(u => u.Id == id));
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        return await Task.FromResult(_users.FirstOrDefault(u => u.Email.Equals(email, StringComparison.OrdinalIgnoreCase)));
    }

    public async Task<User> CreateAsync(CreateUserRequest request)
    {
        var user = new User
        {
            Id = _nextId++,
            Email = request.Email,
            PasswordHash = request.Password, // Should already be hashed
            FirstName = request.FirstName,
            LastName = request.LastName,
            Phone = request.Phone,
            Address = request.Address,
            Role = request.Role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _users.Add(user);
        _logger.LogInformation($"Created user with ID {user.Id}");
        
        return await Task.FromResult(user);
    }

    public async Task<bool> UpdateProfileAsync(int userId, UpdateProfileRequest request)
    {
        var user = _users.FirstOrDefault(u => u.Id == userId);
        if (user == null)
        {
            return false;
        }

        user.FirstName = request.FirstName;
        user.LastName = request.LastName;
        user.Phone = request.Phone;
        user.Address = request.Address;
        user.UpdatedAt = DateTime.UtcNow;

        _logger.LogInformation($"Updated profile for user {userId}");
        return await Task.FromResult(true);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var user = _users.FirstOrDefault(u => u.Id == id);
        if (user == null)
        {
            return false;
        }

        user.IsActive = false;
        _logger.LogInformation($"Soft deleted user {id}");
        return await Task.FromResult(true);
    }

    public async Task<bool> ValidateCredentialsAsync(string email, string password)
    {
        var user = await GetUserByEmailAsync(email);
        if (user == null || !user.IsActive)
        {
            return false;
        }

        return BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
    }
}