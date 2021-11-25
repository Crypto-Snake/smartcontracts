//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract SnakeAppliedArtifactsStruct {
    struct SnakeAppliedArtifacts {
        uint TimesMysteryBoxApplied;
        uint TimesDiamondApplied;
        uint TimesBombApplied;
        uint TimesMouseApplied;
        uint TimesShadowSnakeApplied;
        uint TimesTrophyApplied;
        bool IsRainbowUnicornApplied;
        bool IsSnakeHunterApplied;
        bool IsSnakeCharmerApplied;
        uint TimesSnakeTimeApplied;
    }
}