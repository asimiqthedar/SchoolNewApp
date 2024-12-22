using Microsoft.Extensions.Options;
using School.Models.WebModels;
using System.Data;
using System.Data.SqlClient;

namespace School.Database.WebRepos
{
	public class DbHelper
	{
		AppSettingConfig _AppSettingConfig;
		public DbHelper(IOptions<AppSettingConfig> appSettingConfig)
		{
			_AppSettingConfig = appSettingConfig.Value;
		}
		string GetConnectionString()
		{
			try
			{
				return _AppSettingConfig.ConnectionString;
			}
			catch (Exception)
			{
				throw;
			}
		}
		SqlConnection GetConnection()
		{
			try
			{
				string ConStr = GetConnectionString();
				SqlConnection con = new SqlConnection(ConStr);
				con.Open();
				return con;
			}
			catch (Exception)
			{
				throw;
			}
		}
		public async Task<DataSet> ExecuteDataProcedureAsync(string proc_name, List<SqlParameter> sql_params)
		{
			DataSet ds = new DataSet();
			try
			{
				SqlDataAdapter adapter;
				SqlCommand command = new SqlCommand();
				using (SqlConnection connection = GetConnection())
				{
					try
					{
						command.Connection = connection;
						command.CommandType = CommandType.StoredProcedure;
						command.CommandText = proc_name;
						foreach (var p in sql_params)
						{
							command.Parameters.Add(p);
						}
						adapter = new SqlDataAdapter(command);
						adapter.Fill(ds);
					}
					finally
					{
						connection.Close();
					}
				}
			}
			catch (Exception)
			{
				throw;
			}
			return ds;
		}

		public DataSet ExecuteDataProcedure(string proc_name, List<SqlParameter> sql_params)
		{
			DataSet ds = new DataSet();
			try
			{
				SqlDataAdapter adapter;
				SqlCommand command = new SqlCommand();
				using (SqlConnection connection = GetConnection())
				{
					try
					{
						command.Connection = connection;
						command.CommandType = CommandType.StoredProcedure;
						command.CommandText = proc_name;
						foreach (var p in sql_params)
						{
							command.Parameters.Add(p);
						}
						adapter = new SqlDataAdapter(command);
						adapter.Fill(ds);
					}
					finally
					{
						connection.Close();
					}
				}
			}
			catch (Exception)
			{
				throw;
			}
			return ds;
		}
	}
}
