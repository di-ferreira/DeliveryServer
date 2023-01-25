describe('Rotas caixa', () => {
    let id:number;

    it('Criar caixa - 01', () => {
        cy.request({
            method: 'POST',
            url: '/caixas',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Caixa aberto com sucesso!');
            expect(Response.body[1].total).to.equal(0.00);
            expect(Response.body[1].data).to.equal(Date.now());
            id = Response.body[1].id;
        });
    });
    
    it('Criar caixa com caixa já aberto', () => {        
        cy.request({
            method: 'POST',
            url: '/caixas',
            body: {
                "id": 0,
                "total": 0.00,
                "aberto": true
            }
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body[0].message).to.equal('Caixa já está aberto!');
        });
    });

    it('Buscar caixas', () => {
        cy.request('/caixas')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.gte(1);
            });
    });

    it('Buscar caixas abertos', () => {
        cy.request('/caixas/aberto')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.gte(1);
            });
    });

    it('Buscar caixas fechados', () => {
        cy.request('/caixas/fechados')
            .then((Response) => {
                expect(Response.status).to.equal(200);
                expect(Response.body.count).to.equal(0);
            });
    });

    it('Buscar caixa por ID', () => {
        cy.request(`/caixas/${id}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
        });
    });

    it('Fechar caixa', () => {
        cy.request({
            method: 'PUT',
            url: `/caixas/fechar/${id}`,
            body: {
                "id": id,
                "aberto": false
            }
        }).then(Response => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id);
            expect(Response.body.aberto).to.equal(false);
        });
    });

});