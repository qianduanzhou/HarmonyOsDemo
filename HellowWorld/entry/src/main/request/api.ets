import type { ApiConfig } from "./type";

//api列表
let apiList: Record<string, ApiConfig> = {
  'getVerCode': { // 获取验证码图片
    url: '/system/login/captcha',
  },
  'login': { // 登录
    url: '/auth/oauth/token',
    method: 'POST',
    headers: {
      'Authorization': 'Basic bGluOjEyMzEyMw==',
    },
  },
  'editUserInfo': { // 修改用户信息
    url: '/system/user/updateBySelf',
    method: 'POST',
    headers: {
      'content-type': 'application/json'
    },
    needToken: true
  },
  'uploadBatch': { // 批量上传文件
    url: '/inspection/common/file/uploadBatch',
    method: 'POST',
    headers: {
      'content-type': 'multipart/form-data'
    },
    needToken: true,
    type: 'upload'
  },
  'getCumulative': { // 获取累计值班数
    url: '/inspection/order/app/cumulative'
  },
}




export default apiList;