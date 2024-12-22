using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace School.Web.Helpers
{
	public static class HtmlHelperViewExtensions
    {
        public static async Task<IHtmlContent> RenderActionAsync(this IHtmlHelper helper, string action, object parameters = null)
        {
            var controller = (string)helper.ViewContext.RouteData.Values["controller"];
            return await RenderActionAsync(helper, action, controller, parameters);
        }

        public static async Task<IHtmlContent> RenderActionAsync(this IHtmlHelper helper, string action, string controller, object parameters = null)
        {
            var area = (string)helper.ViewContext.RouteData.Values["area"];
            return await RenderActionAsync(helper, action, controller, area, parameters);
        }

        public static async Task<IHtmlContent> RenderActionAsync(this IHtmlHelper helper, string action, string controller, string area, object parameters = null)
        {
            if (action == null)
                throw new ArgumentNullException(nameof(action));

            if (controller == null)
                throw new ArgumentNullException(nameof(controller));

            return await RenderActionAsyncInternal(helper, action, controller, area, parameters);
        }

        private static async Task<IHtmlContent> RenderActionAsyncInternal(IHtmlHelper helper, string action, string controller, string area, object parameters = null)
        {
            // Fetching required services for invocation
            var currentHttpContext = helper.ViewContext?.HttpContext;
            var httpContextFactory = GetServiceOrFail<IHttpContextFactory>(currentHttpContext);
            var actionInvokerFactory = GetServiceOrFail<IActionInvokerFactory>(currentHttpContext);
            var actionSelector = GetServiceOrFail<IActionDescriptorCollectionProvider>(currentHttpContext);

            // Creating new action invocation context
            var routeData = new RouteData();
            var routeParams = new RouteValueDictionary(parameters ?? new { });
            var routeValues = new RouteValueDictionary(new { area = area, controller = controller, action = action });
            var newHttpContext = httpContextFactory.Create(currentHttpContext.Features);

            newHttpContext.Response.Body = new MemoryStream();

            foreach (var router in helper.ViewContext.RouteData.Routers)
                routeData.PushState(router, null, null);

            routeData.PushState(null, routeValues, null);
            routeData.PushState(null, routeParams, null);

            var actionDescriptor = actionSelector.ActionDescriptors.Items.FirstOrDefault(i => i.RouteValues["controller"] == controller && i.RouteValues["action"] == action);
            var actionContext = new ActionContext(newHttpContext, routeData, actionDescriptor);

            // Invoke action and retrieve the response body
            var invoker = actionInvokerFactory.CreateInvoker(actionContext);
            string content = null;

            await invoker.InvokeAsync().ContinueWith(async task =>
            {
                if (task.IsFaulted)
                {
                    content = task.Exception.Message;
                }
                else if (task.IsCompleted)
                {
                    newHttpContext.Response.Body.Position = 0;
                    using (var reader = new StreamReader(newHttpContext.Response.Body))
                        content = await reader.ReadToEndAsync();
                }
            });

            return new HtmlString(content);
        }

        private static TService GetServiceOrFail<TService>(HttpContext httpContext)
        {
            if (httpContext == null)
                throw new ArgumentNullException(nameof(httpContext));

            var service = httpContext.RequestServices.GetService(typeof(TService));

            if (service == null)
                throw new InvalidOperationException($"Could not locate service: {typeof(TService).FullName}");

            return (TService)service;
        }

        public static string ToHtmlString(this IHtmlContent htmlContent)
        {
            if (htmlContent is HtmlString htmlString)
            {
                return htmlString.Value;
            }

            using (var writer = new StringWriter())
            {
                htmlContent.WriteTo(writer, System.Text.Encodings.Web.HtmlEncoder.Default);
                return writer.ToString();
            }
        }
    }
}
