import { rcp } from '@kit.RemoteCommunicationKit';

// 请求拦截器
class RequestInterceptor implements rcp.Interceptor {
  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const promise = next.handle(context);
    return promise
  }
}

// 响应拦截器
class ResponseInterceptor implements rcp.Interceptor {
  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const promise = next.handle(context);
    return promise
  }
}

class Session {
  public instance: rcp.Session;
  constructor() {
    this.instance = rcp.createSession({
      interceptors: [new RequestInterceptor(), new ResponseInterceptor()],
    });
  }
}

const session = new Session().instance

export default session;