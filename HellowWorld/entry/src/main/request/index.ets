import { RequestOptions, ApiConfig, Result, SuccessRes } from "./type";
import apiList from "./api";
import { rcp } from '@kit.RemoteCommunicationKit';
import session from './session';
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
  // if (api?.needToken) headers.Authorization = 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiIyMjllYzAxYmFkYTNiNzg1MzMyM2E1Y2M4N2RkZmY0ZCIsInByb2R1Y3RfaWQiOiI4ZGFjMTY4ODYxOWQ0MjM4ODRjZTQwZDJjMTA4ZGRjOCIsInNjb3BlIjpbImxpbiJdLCJleHAiOjE3MjQ0MDQ1ODUsImF1dGhvcml0aWVzIjpbIns4ZGFjMTY4ODYxOWQ0MjM4ODRjZTQwZDJjMTA4ZGRjOH1TQkpRekZLNTJHQ1ZobDRTYzJUT1RMMmh5bis3MHNseVNtQWJNSlM4NGVWUVZodlkwYk9JQmN4OTVLYk1pRkpSdGpnajlwWG9aK1VwcWhmbXlQY3BtTW56cTYxR2pNZCtpSm1jbkNrSWFlc0V3RXl2UGtJUTY2a1VYU3NoTG5kci9ES2F4anJDL1dUeEFYMHIydTdYL2ZKSXdXc3BHWTlNOHJ2ZENncTF6OTVFenBsbjhGeUJ5YUwxTkkzSGs4V2ZMaHNlaGFLNzd1VnN2dWo2a05OL0NCZEhhY28yRE80Zy90SUIyUDBwTG56RFlRSlRIMXZyQk9QelhjeWNHUlQ5TzU0SWtxaktJYkFiSFJJZEM4QS9KV0tmNXFtbHpZRVUvL1N5Zzd1MndiRWFZQVdzUWo3dFVFWUJ1RWtlYlJ5Z0FOM2RiYXg3TmZEYWlzaThJUHR5bStRaXd1QVkzbWdMMklLSHFaWVhFVnNtRldNclZmVDh2T1VPUE90N1pWUXRTbnJUeEVUZkN3eThMRG1ZRk1DMFdUQWdrb0cxRlhaMktxSUQ4YkFGelJodmk0U3hVSnRqbnFKR2JSNDlLdXlkTTF5bHhJKzRhKzBTNzFVQVA2NFFONXlLY2FyT1lnMEUzSk9qaGlVOXg0SWNWS3orcS84WmwxSTJnbWp5WTRDZHRnaDFHYjh3TVFLSkV0cWF2Yk5vblhwblpFbnl1QzBFQlZOZ0l3YW9leUZxbGg1eGdTS1ZCTVdTbnFLTUZ1aUJYZ21ZUkQ1SGVnaVE3QmhqZlF6c08xckZUSnQ2aHE1cEdOR0V4K05LbkFRc2I0WS8yZk1OdHVvOVFScVBGTE5WVGhNQUhVUkZkM2xSQy9sK2xTK25vb1JMVWtRMUEzZHVlMzV0RzN4cmlYTmMrQy9uZnFHK0RlQ2tWSGptVXlJaE4rd2F6aTErS2RDMWplcWNiL25RdWFMdDhUV1FNVWpYNFAxOEZSaFk1cnZvRk51WUErSERmU0dzcTdmT1dHbWVkNHZJTVYxMUtXWTZPQU94SlpCeGJ4ZmdacGN5UjJ3MmM0cXV6QTlTV0wwMkVPUzdlWm5VQzUxU1llWGNOT24xZ0ZtWW94c2trUWZXOGt6elp6WGpuRjFXMmVEVmk0TGZ2M25qYXFERE85NGsrSUdnU0oyN0VmQytMUkVwUDhpQWk3NWtNSXhFckFPeC9UZ1hvTUdTQk01bnhuYWNlSjdZVzBjZmlyWW1MQmk1ZGIzWjB5SVJIbEFzSGtlVjNhdWE3T2tuaVNWSnRVeUJGZnM2Znl5bGtHOHloTlIrczhCeW5KSkxtMGg0SENuNWgyODV5ekwvZnRib1ltc3FtTkZLIl0sImp0aSI6Ik1BcEVqaHB4OHZVeVpiTDFFT3ZLQ0xyUDUwSSIsImNsaWVudF9pZCI6ImxpbiJ9.X0pXuDj0TiKbWsoNSUQoWuIYP6i338L7qkeo1j5UVqqAHdsOUyotbJQ5RWlBSDtBCjQRrBjOI9zaWWVWkDrSq76uoszEB_c6SJg_u9XLhU4srAdK6qUrhuPgS6AjSg1Z4grBbwXFgcMQZqSltomoWGH2TfxUdD28-YKeA1ZFPNc'
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
          let json: Result<R> = {
            res: uploadTask as R,
            'err': null
          }
          resolve(json);
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
