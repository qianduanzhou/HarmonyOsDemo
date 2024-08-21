import { RequestOptions, ApiConfig, Result, SuccessRes } from "./type";
import apiList from "./api";
import { rcp } from '@kit.RemoteCommunicationKit';
import session from './Session';
import { BusinessError } from '@kit.BasicServicesKit';
import { request } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { BASE_URL } from 'entry/config';

const options: preferences.Options = { name: 'myStore' };
const dataPreferences: preferences.Preferences = preferences.getPreferencesSync(getContext(), options);


// 辅助函数，用于生成完整的URL
function createFullUrl(endpoint: string): string {
  return `${BASE_URL}${endpoint}`;
}
/**
 * 请求 R 返回data结构， Q 参数结构
 * @param name 接口名称
 * @param query 接口参数
 * @param options 其他选项
 * @returns
 */
function requestApi<R, Q = undefined>(name: string, query?: Q, options?: RequestOptions): Promise<Result<R>> {
  const api: ApiConfig = apiList[name];
  const url = createFullUrl(api.url);
  const method = api.method || 'GET';
  const type = api.type || 'request';
  const headers: rcp.RequestHeaders = api.headers || {};
  let content: rcp.RequestContent = '';
  let reqInstance: rcp.Request;
  let token = dataPreferences?.getSync('token', 'default');
  if (api?.needToken) headers.Authorization = token as string;
  if (method !== 'GET' && type === 'request') {
    if (!headers['content-type']) {
      headers['accept'] = 'application/json';
      content = new rcp.Form(query as rcp.FormFields);
    } else {
      headers['accept'] = headers['content-type'];
      switch (headers['content-type']) {
        case 'application/json':
          content = query as object;
          break;
        case 'multipart/form-data':
          content = new rcp.UploadFromFile(query as string);
          break;
        case 'application/x-www-form-urlencoded':
        default:
          content = new rcp.Form(query as rcp.FormFields);
          break;
      }
    }
  }
  return new Promise((resolve) => {
    if (type === 'request') {
      reqInstance = new rcp.Request(url, method, headers, content);
      session.fetch(reqInstance).then((rep: rcp.Response) => {
        if (rep.statusCode === 500) {
          let json: Result<R> = {
            'err': {
              success: false,
              message: '出错了!',
            }
          }
          resolve(json)
        } else {
          const json = rep.toJSON() as SuccessRes<R>;
          let res: Result<R>
          // 正确的请求
          if (json.success) {
            res = {
              err: null,
              res: json.data
            }
          } else {
            res = {
              err: json
            }
          }
          resolve(res)
        }
      }).catch((err: BusinessError) => {
        let json: Result<R> = {
          'err': err
        }
        resolve(json)
      });
    } else {
      let uploadTask: request.UploadTask;
      let files = query as Array<request.File>
      headers.accept = '*/*';
      let uploadConfig: request.UploadConfig = {
        url,
        header: headers,
        method: "POST",
        files,
        data: [],
      };
      try {
        request.uploadFile(getContext(), uploadConfig).then((data: request.UploadTask) => {
          uploadTask = data;
          uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
            console.info('taskStates', taskStates);
          });
        }).catch((err: BusinessError) => {
          console.error(`Failed to request the upload. Code: ${err.code}, message: ${err.message}`);
          let json: Result<R> = {
            'err': err
          }
          resolve(json)
        });
      } catch (err) {
        console.error(`Failed to request the upload. err: ${JSON.stringify(err)}`);
      }
    }
  })
}

export default requestApi;
