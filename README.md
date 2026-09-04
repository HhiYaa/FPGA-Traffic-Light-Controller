# FPGA Traffic Light Controller

A complete 4-way intersection traffic light controller implemented in VHDL on an FPGA, handling pedestrian/vehicle crossing requests with proper physical signal conditioning and a 16-state finite state machine.

## Overview

This project implements a realistic traffic light controller for a 4-way intersection. Two directions of traffic (North-South and East-West) share the intersection, and pushbuttons let either side request a green light. The system safely conditions the noisy, asynchronous button signals, latches pending requests, and drives a 16-state Moore state machine that sequences the lights fairly between both directions, with live status shown on LEDs and a multiplexed seven-segment display.

## Architecture

The design is split into small, reusable modules connected in a clear signal pipeline:

```
Button (active-low) → Invert → Debounce Filter → Synchronizer → Holding Register → FSM → LEDs + 7-Segment Display
```

- **Invert** — converts the active-low pushbutton signal to active-high for consistent internal logic.
- **Debounce filter** — rejects the electrical "bounce" of a mechanical switch so a single press isn't misread as multiple presses.
- **Synchronizer** — a 2-stage flip-flop synchronizer that safely brings the asynchronous button signal into the FPGA's clock domain, avoiding metastability.
- **Holding register** — latches a crossing request so it isn't lost if it arrives while the FSM is busy servicing the other direction, and clears once the request has been granted.
- **Clock generator** — derives slower timing signals (1 Hz for the FSM's tick, 4 Hz for the yellow-light blink warning) from the board's 50 MHz system clock.
- **Traffic light FSM** — a 16-state Moore machine that cycles each direction through green → yellow → red, checking for a pending request from the other direction and granting it once the current direction has had its turn.
- **Seven-segment mux** — time-division multiplexes a shared display so the current light status can be shown without dedicating a full display to each direction.

## FSM Behavior

The 16 raw states fall into 6 functional phases per direction:

| Phase | Description |
|---|---|
| Green (default) | Direction has the green light, idling/blinking while checking for a request from the other direction |
| Green (extended) | No request pending from the other direction, so the green is extended |
| Yellow | Transition warning before switching to the other direction |

Each direction cycles through its own default green → extended green → yellow phases, then hands off to the other direction. If the waiting direction has a pending request, the FSM skips the "extended green" phase and moves straight to yellow, granting the request sooner rather than holding an already-served direction longer than necessary.

## Files

| File | Purpose |
|---|---|
| `PB_inverters.vhd` | Inverts active-low pushbutton inputs |
| `PB_filters.vhd` | Debounces pushbutton inputs |
| `synchronizer.vhd` | 2-stage synchronizer for clock-domain crossing |
| `holding_register.vhd` | Latches a pending crossing request |
| `clock_generator.vhd` | Derives 1 Hz / 4 Hz timing from the system clock |
| `State_Machine_Example.vhd` | The 16-state traffic light FSM |
| `segment7_mux.vhd` | Multiplexed seven-segment display driver |
| Top-level file | Instantiates and connects all of the above |

## How It Works

1. A pushbutton press on either direction is inverted, debounced, and synchronized into the system clock domain.
2. The synchronized pulse sets a holding register, marking that direction's crossing request as pending.
3. The FSM continuously cycles through its light sequence. When it reaches a checkpoint state, it checks the opposite direction's holding register.
4. If a request is pending, the FSM shortcuts directly to the yellow/transition phase instead of extending the current green, then hands control to the requesting direction.
5. Once a request has been serviced, its holding register is cleared.
6. LEDs display the live light state for both directions, and the seven-segment display shows additional status information, multiplexed across a shared display bus.

## Design Highlights

- **Correct clock-domain crossing** — physical button inputs are properly debounced and synchronized before being used anywhere in the synchronous logic, avoiding the classic beginner mistake of feeding raw async signals directly into an FSM.
- **Fair scheduling** — requests are latched rather than dropped, and the FSM actively checks for pending requests to avoid making a direction wait longer than necessary.
- **Modular design** — each concern (inversion, debouncing, synchronization, latching, timing, display multiplexing) lives in its own small, independently reusable component.

## Tools

Designed and simulated in VHDL, targeting an FPGA development board, using Intel/Altera Quartus for synthesis and simulation.
