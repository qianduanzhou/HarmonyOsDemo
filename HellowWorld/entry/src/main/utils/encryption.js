import sm4 from './sm4'
import WxmpRsa from './wxmp-rsa/index'
import weappJwt from './weapp-jwt.js'

/**
 * 随机生成16位字符串
 */
export function createNonceStr() {
  const chars = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];
  let nums = '';
  for (let i = 0; i < 16; i++) {
    // 这里是几位就要在这里不改变
    const id = parseInt((Math.random() * 61).toString(), 10);
    nums += chars[id];
  }
  return nums;
}

/**
 * sm4加密：将字符串用key（16进制）进行加密
 * @param {string} value 要加密的数据
 * @param {string} key_16 十六进制的key
 */
export function encryptSm4(value, key16) {
  const strEN = sm4.encrypt(value, key16);
  return strEN;
}


/**
 * node-rsa加密：使用公钥加密
 * @param {string} value 要加密的数据
 * @param {string} pubKey 公钥
 */
export function encryptRsa(value, pubKey) {
  const nodeRsa = new WxmpRsa();
  nodeRsa.setPublicKey(pubKey);
  // nodeRsa.importKey(pubKey, 'pkcs8-public')
  const strEN = nodeRsa.encryptLong(value);
  return strEN;
}

/**
 * 字符串转成16进制
 */
export function stringToHex(value) {
  let str = '';
  for (let i = 0; i < value.length; i++) {
    if (value === '') str = value.charCodeAt(i).toString(16);
    else str += value.charCodeAt(i).toString(16);
  }
  return str;
}


/**
 * 加密
 * @param {string} value 要加密的字符串
 * @param {string} publicKey 公钥
 */
export function encryption(value, publicKey) {
  // 随机生成16位字符串的key
  const key = createNonceStr();

  // 转成16进制的key
  const key16 = stringToHex(key);

  // sm4加密：用key_16将密码加密
  const newPassword = encryptSm4(value, key16);
  // node-rsa加密：用公钥将key加密
  const newKeys = encryptRsa(key, publicKey);
  // 拼接
  return `{${newKeys}}${newPassword}`;
}
/**
 * sm4解密：将字符串用key（16进制）进行加密
 * @param {string} value 要解密的数据
 * @param {string} key_16 十六进制的key
 */
export function decryptSm4(value_16, key_16) {
  // const { sm4 } = smCrypto;
  console.log(value_16+":::"+key_16)
  const str = sm4.decrypt(value_16, key_16);
  return str;
}
/**
 * node-rsa解密：使用公钥解密
 * @param {string} value 要解密的数据
 * @param {string} pubKey 公钥
 */
export function decryptRsa(value, pubKey) {
  console.log("value:"+value)
  const nodeRsa = new WxmpRsa();
  nodeRsa.setPrivateKey(pubKey);
  const str = nodeRsa.decrypt(value);
  return str;
}
/**
 * base64转为16进制
 */
export function base64ToHex(base64) {
  // const raw = atob(base64);

  const raw = weappJwt(base64);
  console.log('------------>')
  console.log(raw)
  let HEX = '';

  for (let i = 0; i < raw.length; i++) {
    const _hex = raw.charCodeAt(i).toString(16);

    HEX += _hex.length === 2 ? _hex : `0${_hex}`;
  }
  return HEX.toUpperCase();
}

/**
* 解密
* @param {string} value 要加密的字符串
* @param {string} publicKey 公钥
// */
export function decrypt(value, publicKey) {
  const arr = value.split('}');
  const en_key = arr[0].slice(1);
  const en_text = arr[1];
  if (en_key && en_text) {
    // 1. 先解密出key
    const key = decryptRsa(en_key, publicKey);
    // 2. 用key解密出密码
    const key_16 = stringToHex(key);
    const text_16 = base64ToHex(en_text);
    // 密码的base64转成16进制
    const text = decryptSm4(text_16, key_16);
    return text;
  } else return value;
}
