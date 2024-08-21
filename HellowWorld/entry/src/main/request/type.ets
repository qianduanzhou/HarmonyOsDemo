import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';

// 接口配置
interface ApiConfig {
  url: string //请求url
  method?: string //请求方法，默认为get
  headers?: rcp.RequestHeaders //请求头
  type?: string //request 普通请求 upload 上传文件 download 下载文件
  canCancel?: boolean //是否可以取消请求，默认为false
  needToken?: boolean //是否需要token，默认为true
  showErr?: boolean //是否默认展示错误提示，默认为true
}

// 接口列表配置
interface ApiList {
  getVerCode: ApiConfig
}

// 成功返回值
interface SuccessRes<T> {
  success: boolean
  message: string
  code?: string
  timestamp?: number
  data?: T
}

interface RequestOptions {

}

// 返回值
interface Result<T> {
  err: null | BusinessError | SuccessRes<T>
  res?: T
}

export type { ApiConfig, ApiList, RequestOptions, Result, SuccessRes }