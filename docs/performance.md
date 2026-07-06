# Performance

## What Works

| Component | Status | Notes |
|-----------|--------|-------|
| CPU | ✅ | i5-3337U Ivy Bridge |
| GPU | ✅ | HD 4000 full acceleration |
| Wi-Fi | ✅ | AR9485 2.4GHz |
| Bluetooth | ✅ | AR9462 |
| Ethernet | ✅ | RTL8136 |
| Audio | ✅ | AppleALC (try 1,2,3,7) |
| Battery | ✅ | Percentage & status |
| Sleep/Wake | ✅ | Working |
| Brightness | ✅ | Full control |
| USB | ✅ | After mapping |

## Benchmarks

| Test | Score |
|------|-------|
| Geekbench 5 Single | ~800 |
| Geekbench 5 Multi | ~1600 |
| Metal GPU | ~4500 |

## Real-World Usage

| Task | Performance |
|------|-------------|
| Boot time | 35-45 sec |
| Web browsing | Excellent |
| 4K video | Excellent |
| Gaming | Limited (HD 4000) |

## Battery Life

| Usage | Hours |
|-------|-------|
| Light (web) | 5-6 |
| Video | 4-5 |
| Heavy | 2-3 |

## Gaming

| Game | FPS | Playable |
|------|-----|----------|
| Minecraft | ~40 | ✅ |
| CS:GO | ~60 | ✅ |
| LoL/Dota 2 | ~60 | ✅ |
| Modern AAA | <15 | ❌ |

## Optimization

```bash
# Power settings
sudo pmset -a sleep 10
sudo pmset -a displaysleep 5
sudo pmset -a disksleep 10

# Enable TRIM
sudo trimforce enable
```