package dev.math.zzzopt.core.damage;

public class DamageInput {
    private double health = 0;
    private double attack = 0;
    private double defense = 0;
    private double critRate = 0;
    private double critDamage = 0;
    private double penRatio = 0;
    private double penFlat = 0;
    private double anomalyProf = 0;
    private double anomalyMastery = 0;
    private double energyRegen = 0;
    private double impact = 0;
    private double daze = 0;
    private double sheerForce;
    private double lacerationDamage = 0;
    private double elementalDamage = 0;

    private int attackerLevel = 0;
    private double skillMultiplier = 0;

    private double attributeRes = 0;
    private double allTypeRes = 0;
    private double resReduction = 0;
    private double resPen = 0;

    private double targetBaseDef = 0;
    private double targetDefBonus = 0;
    private double targetDefReduction = 0;
    private double targetDefIgnore = 0;
    private double stunMultTotal = 0;
    private double dmgTakenTotal = 0;
    private double directDmgTotal = 0;
    private double damageTotal = 0;


    public double getAttributeRes() {
        return attributeRes;
    }

    public void setAttributeRes(double attributeRes) {
        this.attributeRes = attributeRes;
    }

    public double getAllTypeRes() {
        return allTypeRes;
    }

    public void setAllTypeRes(double allTypeRes) {
        this.allTypeRes = allTypeRes;
    }

    public double getResReduction() {
        return resReduction;
    }

    public void setResReduction(double resReduction) {
        this.resReduction = resReduction;
    }

    public double getResPen() {
        return resPen;
    }

    public void setResPen(double resPen) {
        this.resPen = resPen;
    }

    public double getTargetBaseDef() {
        return targetBaseDef;
    }

    public void setTargetBaseDef(double targetBaseDef) {
        this.targetBaseDef = targetBaseDef;
    }

    public double getTargetDefBonus() {
        return targetDefBonus;
    }

    public void setTargetDefBonus(double targetDefBonus) {
        this.targetDefBonus = targetDefBonus;
    }

    public double getTargetDefReduction() {
        return targetDefReduction;
    }

    public void setTargetDefReduction(double targetDefReduction) {
        this.targetDefReduction = targetDefReduction;
    }

    public double getTargetDefIgnore() {
        return targetDefIgnore;
    }

    public void setTargetDefIgnore(double targetDefIgnore) {
        this.targetDefIgnore = targetDefIgnore;
    }

    public double getHealth() {
        return health;
    }

    public void setHealth(double health) {
        this.health = health;
    }

    public double getAttack() {
        return attack;
    }

    public void setAttack(double attack) {
        this.attack = attack;
    }

    public double getDefense() {
        return defense;
    }

    public void setDefense(double defense) {
        this.defense = defense;
    }

    public double getCritRate() {
        return critRate;
    }

    public void setCritRate(double critRate) {
        this.critRate = critRate;
    }

    public double getCritDamage() {
        return critDamage;
    }

    public void setCritDamage(double critDamage) {
        this.critDamage = critDamage;
    }

    public double getPenRatio() {
        return penRatio;
    }

    public void setPenRatio(double penRatio) {
        this.penRatio = penRatio;
    }

    public double getPenFlat() {
        return penFlat;
    }

    public void setPenFlat(double penFlat) {
        this.penFlat = penFlat;
    }

    public double getAnomalyProf() {
        return anomalyProf;
    }

    public void setAnomalyProf(double anomalyProf) {
        this.anomalyProf = anomalyProf;
    }

    public double getAnomalyMastery() {
        return anomalyMastery;
    }

    public void setAnomalyMastery(double anomalyMastery) {
        this.anomalyMastery = anomalyMastery;
    }

    public double getEnergyRegen() {
        return energyRegen;
    }

    public void setEnergyRegen(double energyRegen) {
        this.energyRegen = energyRegen;
    }

    public double getImpact() {
        return impact;
    }

    public void setImpact(double impact) {
        this.impact = impact;
    }

    public double getDaze() {
        return daze;
    }

    public void setDaze(double daze) {
        this.daze = daze;
    }

    public double getSheerForce() {
        return sheerForce;
    }

    public void setSheerForce(double sheerForce) {
        this.sheerForce = sheerForce;
    }

    public double getLacerationDamage() {
        return lacerationDamage;
    }

    public void setLacerationDamage(double lacerationDamage) {
        this.lacerationDamage = lacerationDamage;
    }

    public double getElementalDamage() {
        return elementalDamage;
    }

    public void setElementalDamage(double elementalDamage) {
        this.elementalDamage = elementalDamage;
    }

    public int getAttackerLevel() {
        return attackerLevel;
    }

    public void setAttackerLevel(int attackerLevel) {
        this.attackerLevel = attackerLevel;
    }

    public double getSkillMultiplier() {
        return skillMultiplier;
    }

    public void setSkillMultiplier(double skillMultiplier) {
        this.skillMultiplier = skillMultiplier;
    }

    public double getLevelCoefficient(){
        double factor1 = 0.1551 * (attackerLevel * attackerLevel);
        double factor2 = 3.141 * attackerLevel;
        double factor3 = 47.2039;

        return Math.floor(factor1 + factor2 + factor3);
    }

    public double getStunTotal() {
        return stunMultTotal;
    }

    public void setStunTotal(double stunMultTotal) {
        this.stunMultTotal = stunMultTotal;
    }

    public double getDamageTakenTotal() {
        return dmgTakenTotal;
    }

    public void setDamageTakenTotal(double dmgTakenTotal) {
        this.dmgTakenTotal = dmgTakenTotal;
    }

    public double getDirectDmgTotal() {
        return directDmgTotal;
    }

    public void setDirectDmgTotal(double directDmgTotal) {
        this.directDmgTotal = directDmgTotal;
    }

    public double getDamageTotal() {
        return damageTotal;
    }

    public void setDamageTotal(double damageTotal) {
        this.damageTotal = damageTotal;
    }
}
