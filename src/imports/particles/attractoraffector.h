#ifndef ATTRACTORAFFECTOR_H
#define ATTRACTORAFFECTOR_H
#include "particleaffector.h"

class AttractorAffector : public ParticleAffector
{
    Q_OBJECT
    //Like Gravitational singularity, but linear to distance instead of quadratic
    //And affects ds/dt, not da/dt
    Q_PROPERTY(qreal strength READ strength WRITE setStrength NOTIFY strengthChanged)
    Q_PROPERTY(qreal x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(qreal y READ y WRITE setY NOTIFY yChanged)
public:
    explicit AttractorAffector(QObject *parent = 0);
    virtual bool affect(ParticleData *d, qreal dt);

    qreal strength() const
    {
        return m_strength;
    }

    qreal x() const
    {
        return m_x;
    }

    qreal y() const
    {
        return m_y;
    }

signals:

    void strengthChanged(qreal arg);

    void xChanged(qreal arg);

    void yChanged(qreal arg);

public slots:
void setStrength(qreal arg)
{
    if (m_strength != arg) {
        m_strength = arg;
        emit strengthChanged(arg);
    }
}

void setX(qreal arg)
{
    if (m_x != arg) {
        m_x = arg;
        emit xChanged(arg);
    }
}

void setY(qreal arg)
{
    if (m_y != arg) {
        m_y = arg;
        emit yChanged(arg);
    }
}

private:
qreal m_strength;
qreal m_x;
qreal m_y;
};

#endif // ATTRACTORAFFECTOR_H