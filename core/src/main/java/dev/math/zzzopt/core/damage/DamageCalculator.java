package dev.math.zzzopt.core.damage;

public class DamageCalculator {
    public double calculate(DamageInput input) {

        return baseDamageMod(input)
        * damageMod(input)
        * critMod(input)
        * resMod(input)
        * defMod(input)
        * stunMod(input)
        * damageTakenMod(input)
        * directDamageMod(input);
    }

    private double baseDamageMod (DamageInput input){
        return input.getAttack() * input.getSkillMultiplier();
    }

    private double damageMod (DamageInput input){
        return 1 + input.getDamageTotal();
    }

    private double critMod (DamageInput input){
        return 1 + input.getCritDamage();
    }

    private double avgCritMod (DamageInput input){
        return 1 + input.getCritRate() * input.getCritDamage();
    }

    private double resMod (DamageInput input){
        return 1
                - input.getAttributeRes()
                - input.getAllTypeRes()
                + input.getResReduction()
                + input.getResPen();
    }

    private double defMod (DamageInput input){
        double targetDef = input.getTargetBaseDef()
                * (1 + input.getTargetDefBonus() - input.getTargetDefReduction() - input.getTargetDefIgnore());

        double effectiveDef = targetDef * (1 - input.getPenRatio()) - input.getPenFlat();

        return input.getLevelCoefficient() / (input.getLevelCoefficient() + effectiveDef);

    }

    private double stunMod(DamageInput input){
        // 1 + Somatório stun bonus%
        return 1 + input.getStunTotal();
    }

    private double damageTakenMod(DamageInput input){
        // 1 - Somatório DMG Reduc + Somatório DMG Taken
        return 1 + input.getDamageTakenTotal();
    }

    private double directDamageMod (DamageInput input){
        // 1 + somatório direct dmg%
        return 1 + input.getDirectDmgTotal();
    }

}
