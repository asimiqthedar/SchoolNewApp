using Microsoft.EntityFrameworkCore;
using School.Common.Helpers;
using School.Services.Entities;

namespace School.Services.ALSManager
{
	public interface IUserManager
    {
        Task<TblUser> GetUserByEmail(string userEmail);
        Task SaveOtp(int userId, string otp, DateTime otpExpiration);
        Task SaveNewPassword(int userId, string newPassword);
    }
    public class UserManager : IUserManager
    {
        private readonly ALSContext _ALSContextDB;
        public UserManager(ALSContext aLSContextDB)
        {
            _ALSContextDB = aLSContextDB;
        }

        public async Task<TblUser> GetUserByEmail(string userEmail)
		{
            try
            {
                return await _ALSContextDB.TblUsers.FirstOrDefaultAsync(s => s.UserEmail == userEmail);
            }
			catch (Exception ex)
			{
				//_logger.LogError($"Exception:DropdownService:GetAppDropdown : Message :{JsonConvert.SerializeObject(ex)}");
				throw ex;
			}
		}

        public async Task SaveOtp(int userId, string otp, DateTime otpExpiration)
        {
            var user = await _ALSContextDB.TblUsers.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user != null) { 
                user.Otp = otp;
                user.OtpExpiration = otpExpiration;
                await _ALSContextDB.SaveChangesAsync();
            }

        }

        public async Task SaveNewPassword(int userId, string newPassword)
        {
            var user = await _ALSContextDB.TblUsers.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user != null)
            {
                var hashedPassword = Utility.Encrypt(newPassword, false);
                user.UserPass = hashedPassword;
                user.Otp = null;
                user.OtpExpiration = null;
                await _ALSContextDB.SaveChangesAsync();
            }

        }


    }
}
