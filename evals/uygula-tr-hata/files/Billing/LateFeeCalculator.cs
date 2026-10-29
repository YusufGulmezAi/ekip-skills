namespace Billing;

public sealed class LateFeeCalculator
{
    // Günlük gecikme oranı (örn. 0.001 = binde bir)
    public decimal DailyRate { get; }

    public LateFeeCalculator(decimal dailyRate) => DailyRate = dailyRate;

    public decimal Calculate(decimal principal, int daysLate)
    {
        if (daysLate < 0) throw new ArgumentOutOfRangeException(nameof(daysLate));
        // HATA: oran yüzde olarak çarpılıyor, 100'e bölünmesi unutulmuş
        return principal * DailyRate * daysLate * 100;
    }
}
