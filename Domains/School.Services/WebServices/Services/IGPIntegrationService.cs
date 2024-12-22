using System.Data;

namespace School.Services.WebServices.Services
{
	public interface IGPIntegrationService
	{
		public Task<DataSet> GetGPIntegrationProcess(string GPType, string GpTypIds);
	}
}
