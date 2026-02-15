class MockSingBoxConfig {
  // Simple test config (direct connection, no real VPN server needed)
  static const String testConfig = '''
{
  "log": {
    {
  "log": {
    "level": "info",
    "timestamp": true
  },

  "dns": {
    "servers": [
      {
        "tag": "dns-direct",
        "address": "223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "dns-proxy",
        "address": "tls://1.1.1.1",
        "detour": "proxy"
      },
      {
        "tag": "dns-block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-direct"
      },
      {
        "clash_mode": "direct",
        "server": "dns-direct"
      },
      {
        "clash_mode": "global",
        "server": "dns-proxy"
      }
    ],
    "final": "dns-proxy",
    "strategy": "prefer_ipv4",
    "independent_cache": true
  },

  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "inet4_address": "172.19.0.2/30",
      "mtu": 1400,
      "stack": "gvisor",
      "sniff": true,
      "sniff_override_destination": true
    }
  ],

  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": ["auto", "hysteria2", "direct"],
      "default": "auto"
    },

    {
      "type": "urltest",
      "tag": "auto",
      "outbounds": [
        "wireguard-device1",
        "wireguard-device2",
        "wireguard-device3",
        "hysteria2"
      ],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "10m",
      "tolerance": 50
    },

    {
      "type": "wireguard",
      "tag": "wireguard-device1",
      "server": "51.75.126.238",
      "server_port": 53050,
      "system_interface": false,
      "local_address": ["10.155.0.2/32"],
      "private_key": "QNfDN54TBS7znkepTc5DTyKJZbOb/Wo3j8gExmfTTGc=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },

    {
      "type": "wireguard",
      "tag": "wireguard-device2",
      "server": "51.75.126.238",
      "server_port": 53050,
      "system_interface": false,
      "local_address": ["10.155.0.4/32"],
      "private_key": "SDQWsGLhy744maFA/WpgkPWAw7UKfc+UCCwXBalEm1s=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },

    {
      "type": "wireguard",
      "tag": "wireguard-device3",
      "server": "51.75.126.238",
      "server_port": 53050,
      "system_interface": false,
      "local_address": ["10.155.0.3/32"],
      "private_key": "mMYiyJnyb317OsVZkf2PG9MTOWqLwC749mFHmaf1o30=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },

    {
      "type": "shadowsocks",
      "tag": "ss-out",
      "server": "51.75.126.238",
      "server_port": 443,
      "method": "2022-blake3-aes-256-gcm",
      "password": "yK8mN3pQ7vR2xT9wU5hJ6kL1mN4oP8qS3tV7wX0yZ2a=",
      "multiplex": {
        "enabled": true,
        "protocol": "h2mux",
        "max_connections": 4,
        "min_streams": 4,
        "padding": true
      },
      "tcp_fast_open": true
    },

    {
      "type": "hysteria2",
      "tag": "hysteria2",
      "server": "51.75.126.238",
      "server_port": 8443",
      "password": "kvAsyCT3ZsYAz22J/fC5T6i35jmxNvEfZcmRpWBCm40=",
      "tls": {
        "enabled": true,
        "server_name": "server.vulcainvpn.com",
        "alpn": ["h3"]
      },
      "up_mbps": 100,
      "down_mbps": 100,
      "obfs": {
        "type": "salamander",
        "password": "AYo3SryNibASrSRyMwzyBLxA45YsASzrSr7c8DSMUU0="
      }
    },

    {
      "type": "direct",
      "tag": "direct"
    },

    {
      "type": "block",
      "tag": "block"
    },

    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],

  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      }
    ],
    "final": "proxy"
  },

  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "store_fakeip": true
    }
  }
}
"level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-direct",
        "address": "223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "dns-proxy",
        "address": "tls://1.1.1.1",
        "detour": "proxy"
      },
      {
        "tag": "dns-block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "outbound": "any",
        "server": "dns-direct"
      },
      {
        "clash_mode": "direct",
        "server": "dns-direct"
      },
      {
        "clash_mode": "global",
        "server": "dns-proxy"
      }
    ],
    "final": "dns-proxy",
    "strategy": "prefer_ipv4",
    "disable_cache": false,
    "disable_expire": false,
    "independent_cache": true
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "tun0",
      "inet4_address": "172.19.0.1/30",
      "mtu": 1400,
      "auto_route": true,
      "strict_route": true,
      "stack": "mixed",
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": ["auto", "hysteria2", "direct"],
      "default": "auto"
    },
    {
      "type": "urltest",
      "tag": "auto",
      "outbounds": ["wireguard-device1", "wireguard-device2", "wireguard-device3", "hysteria2"],
      "url": "https://www.gstatic.com/generate_204",
      "interval": "10m",
      "tolerance": 50
    },
    {
      "type": "wireguard",
      "tag": "wireguard-device1",
      "server": "51.75.126.238",
      "server_port": 53050,
      "system_interface": false,
      "interface_name": "wg0",
      "local_address": ["10.155.0.2/32"],
      "private_key": "QNfDN54TBS7znkepTc5DTyKJZbOb/Wo3j8gExmfTTGc=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },
    {
      "type": "wireguard",
      "tag": "wireguard-device2",
      "server": "51.75.126.238",
      "server_port": 53050,
      "local_address": ["10.155.0.4/32"],
      "private_key": "SDQWsGLhy744maFA/WpgkPWAw7UKfc+UCCwXBalEm1s=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },
    {
      "type": "wireguard",
      "tag": "wireguard-device3",
      "server": "51.75.126.238",
      "server_port": 53050,
      "local_address": ["10.155.0.3/32"],
      "private_key": "mMYiyJnyb317OsVZkf2PG9MTOWqLwC749mFHmaf1o30=",
      "peer_public_key": "ldvntMa1jvroOvcHXeg73/PTKvp/SJs3i4EuiG1Mq0o=",
      "mtu": 1280,
      "detour": "ss-out"
    },
    {
      "type": "shadowsocks",
      "tag": "ss-out",
      "server": "51.75.126.238",
      "server_port": 443,
      "method": "2022-blake3-aes-256-gcm",
      "password": "yK8mN3pQ7vR2xT9wU5hJ6kL1mN4oP8qS3tV7wX0yZ2a=",
      "multiplex": {
        "enabled": true,
        "protocol": "h2mux",
        "max_connections": 4,
        "min_streams": 4,
        "padding": true
      },
      "tcp_fast_open": true
    },
    {
      "type": "hysteria2",
      "tag": "hysteria2",
      "server": "51.75.126.238",
      "server_port": 8443,
      "password": "kvAsyCT3ZsYAz22J/fC5T6i35jmxNvEfZcmRpWBCm40=",
      "tls": {
        "enabled": true,
        "server_name": "server.vulcainvpn.com",
        "alpn": ["h3"],
        "insecure": false
      },
      "up_mbps": 100,
      "down_mbps": 100,
      "obfs": {
        "type": "salamander",
        "password": "AYo3SryNibASrSRyMwzyBLxA45YsASzrSr7c8DSMUU0="
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      }
    ],
    "auto_detect_interface": true,
    "final": "proxy"
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "store_fakeip": true
    },
    "clash_api": {
      "external_controller": "127.0.0.1:9090",
      "secret": "",
      "default_mode": "rule"
    }
  }
}
''';
}
