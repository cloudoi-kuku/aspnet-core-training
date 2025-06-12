using ECommerce.API.Models;
using ECommerce.API.DTOs;

namespace ECommerce.API.Services;

public interface IUserService
{
    Task<IEnumerable<User>> GetAllAsync();
    Task<User?> GetByIdAsync(int id);
    Task<User?> GetUserByEmailAsync(string email);
    Task<User> CreateAsync(CreateUserRequest request);
    Task<bool> UpdateProfileAsync(int userId, UpdateProfileRequest request);
    Task<bool> DeleteAsync(int id);
    Task<bool> ValidateCredentialsAsync(string email, string password);
}