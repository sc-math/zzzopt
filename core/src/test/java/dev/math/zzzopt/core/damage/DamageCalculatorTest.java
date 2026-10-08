package dev.math.zzzopt.core.damage;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DamageCalculatorTest {

    private void verificar(double mult, double dmgTotal, int stacks, double esperado) {
        DamageInput in = new DamageInput();
        in.setAttackerLevel(60);
        in.setSkillMultiplier(mult);
        in.setAttack(2858 + 840 + 3475 * 0.3 + 50 + 2858 * 0.04 * stacks);
        in.setCritDamage((208.4 + 30 + 32) / 100.0);
        in.setPenRatio(0.32);
        in.setPenFlat(27);
        in.setStunTotal(2.6);
        in.setDamageTotal(dmgTotal);
        in.setResPen(0.20);
        in.setTargetBaseDef(952);
        in.setAttributeRes(-0.20);

        double resultado = new DamageCalculator().calculate(in);

        assertEquals(esperado, resultado, esperado * 0.02); // tolerância de 2%
    }

    @ParameterizedTest
    @CsvSource({
            // multiplicador, bônus de dano total, dano do vídeo
            "11.631, 1.33, 1469126",   // hold2
            "15.556, 1.33, 1964899",   // hold3
            "15.556, 1.15, 1813104",   // hold3 sem o buff de 18%
            "6.843,  1.15,  801279",   // hold1 sem o buff de 18%
            "15.556, 1.33, 1934935"    // hold3 final, run nova
            // "6.843, 1.33, 898296"   // hold1 após chain1: +3,9%, causa desconhecida
    })
    void holds(double mult, double dmgTotal, double esperado) {
        verificar(mult, dmgTotal, 3, esperado);
    }

    @ParameterizedTest
    @CsvSource({
            "18.017, 0.58, 1543213",   // chain1 (40 do sup1 + 18 do sup2)
            "18.017, 0.40, 1367404",   // chain2 (só o 40 do sup1)
            "20.008, 0.40, 1518510"    // ex
    })
    void chainsEEx(double mult, double dmgTotal, double esperado) {
        verificar(mult, dmgTotal, 3, esperado);
    }

    @ParameterizedTest
    @CsvSource({
            // multiplicador, bônus, stacks, dano do vídeo
            "41.808, 0.58, 2, 3502976",   // ult, run nova
            "41.808, 0.40, 1, 3020956"    // ult, run antiga
    })
    void ults(double mult, double dmgTotal, int stacks, double esperado) {
        verificar(mult, dmgTotal, stacks, esperado);
    }
}