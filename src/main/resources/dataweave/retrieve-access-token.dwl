%dw 2.0
output application/json
---
{
    access_token: vars['vAccessToken'],
    refresh_token: vars['vRefreshToken']
}